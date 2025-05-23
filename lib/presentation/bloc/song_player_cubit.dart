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
  
  // New properties for enhanced functionality
  List<SongEntity> playlist = [];
  int currentSongIndex = 0;
  bool isShuffleEnabled = false;
  LoopMode repeatMode = LoopMode.off;
  List<int> shuffledIndices = [];
  int currentShuffleIndex = 0;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateSongPlayer();
    });

    audioPlayer.durationStream.listen((duration) {
      songDuration = duration ?? Duration.zero;
    });

    // Listen for when a song completes
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  void updateSongPlayer() {
    emit(SongPlayerLoaded());
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
    emit(SongPlayerLoaded());
  }

  void updateSeekPosition(Duration position) {
    songPosition = position;
    emit(SongPlayerLoaded());
  }

  // Enhanced loadSong method that accepts playlist
  Future<void> loadSong(String url, {List<SongEntity>? songPlaylist, int? initialIndex}) async {
    try {
      if (songPlaylist != null) {
        playlist = songPlaylist;
        currentSongIndex = initialIndex ?? 0;
        _generateShuffledIndices();
      }
      
      await audioPlayer.setUrl(url);
      emit(SongPlayerLoaded());
    } catch (e) {
      emit(SongPlayerLoadingFailure());
    }
  }

  // Original loadSong method for backward compatibility
  Future<void> loadSingleSong(String url) async {
    try {
      await audioPlayer.setUrl(url);
      emit(SongPlayerLoaded());
    } catch (e) {
      emit(SongPlayerLoadingFailure());
    }
  }

  void playOrPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  // New method: Play previous song
  Future<void> playPreviousSong() async {
    if (playlist.isEmpty) return;

    if (isShuffleEnabled) {
      currentShuffleIndex = (currentShuffleIndex - 1 + shuffledIndices.length) % shuffledIndices.length;
      currentSongIndex = shuffledIndices[currentShuffleIndex];
    } else {
      currentSongIndex = (currentSongIndex - 1 + playlist.length) % playlist.length;
    }

    await _loadCurrentSong();
  }

  // New method: Play next song
  Future<void> playNextSong() async {
    if (playlist.isEmpty) return;

    if (isShuffleEnabled) {
      currentShuffleIndex = (currentShuffleIndex + 1) % shuffledIndices.length;
      currentSongIndex = shuffledIndices[currentShuffleIndex];
    } else {
      currentSongIndex = (currentSongIndex + 1) % playlist.length;
    }

    await _loadCurrentSong();
  }

  // New method: Toggle shuffle
  void toggleShuffle() {
    isShuffleEnabled = !isShuffleEnabled;
    if (isShuffleEnabled) {
      _generateShuffledIndices();
      // Find current song in shuffle list
      currentShuffleIndex = shuffledIndices.indexOf(currentSongIndex);
    }
    emit(SongPlayerLoaded());
  }

  // New method: Toggle repeat mode
  void toggleRepeat() {
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
    emit(SongPlayerLoaded());
  }

  // Private method: Generate shuffled indices
  void _generateShuffledIndices() {
    shuffledIndices = List.generate(playlist.length, (index) => index);
    shuffledIndices.shuffle(Random());
    currentShuffleIndex = shuffledIndices.indexOf(currentSongIndex);
  }

  // Private method: Load current song based on index
  Future<void> _loadCurrentSong() async {
    if (playlist.isNotEmpty && currentSongIndex < playlist.length) {
      final currentSong = playlist[currentSongIndex];
      final url = "${AppUrls.songFirestorage}${Uri.encodeComponent('${currentSong.artist} - ${currentSong.title}.mp3')}?${AppUrls.mediaAlt}";
      
      try {
        await audioPlayer.setUrl(url);
        audioPlayer.play();
        emit(SongPlayerLoaded());
      } catch (e) {
        emit(SongPlayerLoadingFailure());
      }
    }
  }

  // Private method: Handle song completion
  void _handleSongCompletion() {
    if (repeatMode == LoopMode.one) {
      audioPlayer.seek(Duration.zero);
      audioPlayer.play();
    } else if (repeatMode == LoopMode.all || repeatMode == LoopMode.off) {
      if (playlist.isNotEmpty) {
        playNextSong();
      }
    }
  }

  // Getter for current song
  SongEntity? get currentSong {
    if (playlist.isNotEmpty && currentSongIndex < playlist.length) {
      return playlist[currentSongIndex];
    }
    return null;
  }

  // Getter for repeat mode icon
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

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}