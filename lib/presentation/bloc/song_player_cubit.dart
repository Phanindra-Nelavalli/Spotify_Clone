import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/bloc/song_player_state.dart';
import 'dart:math';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  
  // Enhanced properties for playlist functionality
  List<SongEntity> playlist = [];
  int currentSongIndex = 0;
  bool isShuffleEnabled = false;
  LoopMode repeatMode = LoopMode.off;
  List<int> shuffledIndices = [];
  int currentShuffleIndex = 0;
  
  // Flag to prevent multiple simultaneous song loads
  bool _isLoadingSong = false;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Listen to position changes
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      if (!isClosed) {
        updateSongPlayer();
      }
    });

    // Listen to duration changes
    audioPlayer.durationStream.listen((duration) {
      songDuration = duration ?? Duration.zero;
      if (!isClosed) {
        updateSongPlayer();
      }
    });

    // Listen for player state changes
    audioPlayer.playerStateStream.listen((playerState) {
      if (!isClosed) {
        if (playerState.processingState == ProcessingState.completed) {
          _handleSongCompletion();
        }
        updateSongPlayer();
      }
    });
  }

  void updateSongPlayer() {
    if (!isClosed) {
      emit(SongPlayerLoaded());
    }
  }

  void seekTo(Duration position) {
    if (position <= songDuration) {
      audioPlayer.seek(position);
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    }
  }

  void updateSeekPosition(Duration position) {
    if (position <= songDuration) {
      songPosition = position;
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    }
  }

  // Enhanced loadSong method that accepts playlist
  Future<void> loadSong(String url, {List<SongEntity>? songPlaylist, int? initialIndex}) async {
    if (_isLoadingSong) return;
    _isLoadingSong = true;

    try {
      // Reset position tracking when loading new song
      songPosition = Duration.zero;
      songDuration = Duration.zero;
      
      if (songPlaylist != null && songPlaylist.isNotEmpty) {
        playlist = List.from(songPlaylist); // Create a copy to avoid reference issues
        currentSongIndex = (initialIndex ?? 0).clamp(0, playlist.length - 1);
        _generateShuffledIndices();
      }
      
      await audioPlayer.setUrl(url);
      // Ensure song starts from the beginning
      await audioPlayer.seek(Duration.zero);
      
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error loading song: $e');
      if (!isClosed) {
        emit(SongPlayerLoadingFailure());
      }
    } finally {
      _isLoadingSong = false;
    }
  }

  // Original loadSong method for backward compatibility
  Future<void> loadSingleSong(String url) async {
    if (_isLoadingSong) return;
    _isLoadingSong = true;

    try {
      await audioPlayer.setUrl(url);
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error loading single song: $e');
      if (!isClosed) {
        emit(SongPlayerLoadingFailure());
      }
    } finally {
      _isLoadingSong = false;
    }
  }

  void playOrPause() {
    try {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error in playOrPause: $e');
    }
  }

  // Spotify-like previous button functionality
  Future<void> playPreviousSong() async {
    if (_isLoadingSong) return;

    try {
      // If more than 3 seconds have passed, restart current song
      if (songPosition.inSeconds > 3) {
        await audioPlayer.seek(Duration.zero);
        if (!audioPlayer.playing) {
          audioPlayer.play();
        }
        return;
      }

      // If playlist is empty or has only one song, restart current song
      if (playlist.isEmpty || playlist.length == 1) {
        await audioPlayer.seek(Duration.zero);
        if (!audioPlayer.playing) {
          audioPlayer.play();
        }
        return;
      }

      // Go to previous song in playlist
      if (isShuffleEnabled) {
        currentShuffleIndex = (currentShuffleIndex - 1 + shuffledIndices.length) % shuffledIndices.length;
        currentSongIndex = shuffledIndices[currentShuffleIndex];
      } else {
        currentSongIndex = (currentSongIndex - 1 + playlist.length) % playlist.length;
      }

      await _loadCurrentSong();
    } catch (e) {
      print('Error in playPreviousSong: $e');
      if (!isClosed) {
        emit(SongPlayerLoadingFailure());
      }
    }
  }

  // Forward button - always go to next song
  Future<void> playNextSong() async {
    if (_isLoadingSong) return;

    try {
      // If playlist is empty, do nothing
      if (playlist.isEmpty) return;

      // If playlist has only one song, restart it
      if (playlist.length == 1) {
        await audioPlayer.seek(Duration.zero);
        audioPlayer.play();
        return;
      }

      // Go to next song in playlist
      if (isShuffleEnabled) {
        currentShuffleIndex = (currentShuffleIndex + 1) % shuffledIndices.length;
        currentSongIndex = shuffledIndices[currentShuffleIndex];
      } else {
        currentSongIndex = (currentSongIndex + 1) % playlist.length;
      }

      await _loadCurrentSong();
    } catch (e) {
      print('Error in playNextSong: $e');
      if (!isClosed) {
        emit(SongPlayerLoadingFailure());
      }
    }
  }

  // Toggle shuffle functionality
  void toggleShuffle() {
    try {
      isShuffleEnabled = !isShuffleEnabled;
      if (isShuffleEnabled && playlist.isNotEmpty) {
        _generateShuffledIndices();
        // Find current song in shuffle list
        currentShuffleIndex = shuffledIndices.indexOf(currentSongIndex);
        if (currentShuffleIndex == -1) {
          currentShuffleIndex = 0;
        }
      }
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error in toggleShuffle: $e');
    }
  }

  // Toggle repeat mode
  void toggleRepeat() {
    try {
      switch (repeatMode) {
        case LoopMode.off:
          repeatMode = LoopMode.all;
          break;
        case LoopMode.all:
          repeatMode = LoopMode.one;
          break;
        case LoopMode.one:
          repeatMode = LoopMode.off;
          break;
      }
      audioPlayer.setLoopMode(repeatMode);
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error in toggleRepeat: $e');
    }
  }

  // Private method: Generate shuffled indices
  void _generateShuffledIndices() {
    if (playlist.isEmpty) return;
    
    shuffledIndices = List.generate(playlist.length, (index) => index);
    shuffledIndices.shuffle(Random());
    
    // Ensure current song is not shuffled to first position unless it was already there
    if (shuffledIndices.isNotEmpty && currentSongIndex < playlist.length) {
      currentShuffleIndex = shuffledIndices.indexOf(currentSongIndex);
      if (currentShuffleIndex == -1) {
        currentShuffleIndex = 0;
      }
    }
  }

  // Private method: Load current song based on index
  Future<void> _loadCurrentSong() async {
    if (_isLoadingSong || playlist.isEmpty || currentSongIndex >= playlist.length) {
      return;
    }

    _isLoadingSong = true;

    try {
      // Reset position tracking when loading new song
      songPosition = Duration.zero;
      songDuration = Duration.zero;
      
      // Emit loading state
      if (!isClosed) {
        emit(SongPlayerLoading());
      }

      final currentSong = playlist[currentSongIndex];
      final url = "${AppUrls.songFirestorage}${Uri.encodeComponent('${currentSong.artist} - ${currentSong.title}.mp3')}?${AppUrls.mediaAlt}";
      
      await audioPlayer.setUrl(url);
      // Ensure song starts from the beginning
      await audioPlayer.seek(Duration.zero);
      audioPlayer.play();
      
      if (!isClosed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      print('Error loading current song: $e');
      if (!isClosed) {
        emit(SongPlayerLoadingFailure());
      }
    } finally {
      _isLoadingSong = false;
    }
  }

  // Private method: Handle song completion
  void _handleSongCompletion() {
    if (isClosed) return;

    try {
      if (repeatMode == LoopMode.one) {
        audioPlayer.seek(Duration.zero);
        audioPlayer.play();
      } else if (playlist.isNotEmpty) {
        if (repeatMode == LoopMode.all) {
          playNextSong();
        } else if (repeatMode == LoopMode.off) {
          // Check if we're at the end of the playlist
          bool isLastSong = isShuffleEnabled 
              ? currentShuffleIndex == shuffledIndices.length - 1
              : currentSongIndex == playlist.length - 1;
          
          if (!isLastSong) {
            playNextSong();
          }
        }
      }
    } catch (e) {
      print('Error in _handleSongCompletion: $e');
    }
  }

  // Safe getter for current song
  SongEntity? get currentSong {
    if (playlist.isNotEmpty && 
        currentSongIndex >= 0 && 
        currentSongIndex < playlist.length) {
      return playlist[currentSongIndex];
    }
    return null;
  }

  // Getter for repeat mode text
  String get repeatModeText {
    switch (repeatMode) {
      case LoopMode.off:
        return 'off';
      case LoopMode.all:
        return 'all';
      case LoopMode.one:
        return 'one';
    }
  }

  // Check if previous button should be enabled
  bool get canGoPrevious {
    return playlist.isNotEmpty && (playlist.length > 1 || songPosition.inSeconds > 3);
  }

  // Check if next button should be enabled
  bool get canGoNext {
    return playlist.isNotEmpty && playlist.length > 1;
  }

  // Check if a song is currently loading
  bool get isLoadingSong => _isLoadingSong;

  @override
  Future<void> close() {
    _isLoadingSong = false;
    audioPlayer.dispose();
    return super.close();
  }
}