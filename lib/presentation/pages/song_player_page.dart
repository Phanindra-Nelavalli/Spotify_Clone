import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:spotify/common/widgets/favourite_button.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/bloc/song_player_state.dart';
import 'package:just_audio/just_audio.dart';

class SongPlayerPage extends StatelessWidget {
  final SongEntity song;
  final List<SongEntity>? playlist;
  final int? initialIndex;

  const SongPlayerPage({
    super.key,
    required this.song,
    this.playlist,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: Text(
          "Now Playing",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        action: IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert_rounded, size: 29),
        ),
      ),
      body: BlocProvider(
        create: (_) => SongPlayerCubit()..loadSong(
          "${AppUrls.songFirestorage}${Uri.encodeComponent('${song.artist} - ${song.title}.mp3')}?${AppUrls.mediaAlt}",
          songPlaylist: playlist,
          initialIndex: initialIndex,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: BlocBuilder<SongPlayerCubit, SongPlayerState>(
            builder: (context, state) {
              if (state is SongPlayerLoadingFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load song',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              final cubit = context.read<SongPlayerCubit>();
              final currentSong = cubit.currentSong ?? song;

              return Column(
                children: [
                  _songCover(currentSong, context),
                  SizedBox(height: 17),
                  _songDetails(currentSong),
                  SizedBox(height: 20),
                  _songPlayer(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _songCover(SongEntity song, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            "${AppUrls.firestorage}${Uri.encodeComponent('${song.artist} - ${song.title}.jpg')}?${AppUrls.mediaAlt}",
          ),
          onError: (exception, stackTrace) {
            print('Error loading image: $exception');
          },
        ),
      ),
    );
  }

  Widget _songDetails(SongEntity song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        FavouriteButton(songEntity: song, size: 35),
      ],
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoaded) {
          final cubit = context.read<SongPlayerCubit>();

          return Column(
            children: [
              // Progress Slider (simplified - no loading animation)
              _buildProgressSlider(cubit),

              // Time Display
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(cubit.songPosition),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    formatDuration(cubit.songDuration),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              // Control Buttons Row
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle Button
                  _buildControlButton(
                    icon: Icons.shuffle,
                    isActive: cubit.isShuffleEnabled,
                    onTap: cubit.playlist.length > 1 ? () => cubit.toggleShuffle() : null,
                    size: 24,
                    context: context
                  ),

                  // Previous Button (Spotify-like behavior)
                  _buildControlButton(
                    icon: Icons.skip_previous_rounded,
                    isActive: false,
                    onTap: cubit.canGoPrevious 
                        ? () => cubit.playPreviousSong() 
                        : null,
                    size: 32,
                    context: context,
                    showTooltip: true,
                    tooltipMessage: cubit.songPosition.inSeconds > 3 
                        ? "Restart song" 
                        : "Previous song",
                  ),

                  // Play/Pause Button (simplified - no loading animation)
                  GestureDetector(
                    onTap: () => cubit.playOrPause(),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        cubit.audioPlayer.playing
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        size: 32,
                        color: Colors.white,
                        
                      ),
                    ),
                  ),

                  // Next Button
                  _buildControlButton(
                    icon: Icons.skip_next_rounded,
                    isActive: false,
                    onTap: cubit.canGoNext 
                        ? () => cubit.playNextSong() 
                        : null,
                    size: 32,
                    context: context
                  ),

                  // Repeat Button
                  _buildControlButton(
                    icon: cubit.repeatMode == LoopMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    isActive: cubit.repeatMode != LoopMode.off,
                    onTap: () => cubit.toggleRepeat(),
                    size: 24,
                    context: context
                  ),
                ],
              ),

              // Playlist info and current position
              if (cubit.playlist.isNotEmpty) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.queue_music, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "${cubit.currentSongIndex + 1} of ${cubit.playlist.length}",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      if (cubit.isShuffleEnabled) ...[
                        SizedBox(width: 8),
                        Icon(Icons.shuffle, size: 12, color: AppColors.primary),
                      ],
                    ],
                  ),
                ),
              ],

              // Show loading indicator when switching songs (kept this one)
              if (cubit.isLoadingSong)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading next song...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        // Loading state
        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading song...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
    required double size,
    bool showTooltip = false,
    String? tooltipMessage,
    BuildContext ?context,
  }) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size == 32 ? 12 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: size,
          color: onTap != null
              ? (isActive ? AppColors.primary : (context?.isDarkMode ?? false) ? Colors.grey : Colors.white)
              : Colors.grey,
        ),
      ),
    );

    if (showTooltip && tooltipMessage != null) {
      return Tooltip(
        message: tooltipMessage,
        child: button,
      );
    }

    return button;
  }

  Widget _buildProgressSlider(SongPlayerCubit cubit) {
    return Slider(
      activeColor: AppColors.primary,
      inactiveColor: Colors.grey.withOpacity(0.3),
      value: cubit.songDuration.inSeconds > 0
          ? cubit.songPosition.inSeconds.toDouble().clamp(
              0.0, cubit.songDuration.inSeconds.toDouble())
          : 0.0,
      min: 0.0,
      max: cubit.songDuration.inSeconds > 0
          ? cubit.songDuration.inSeconds.toDouble()
          : 1.0,
      onChanged: cubit.songDuration.inSeconds > 0
          ? (value) {
              cubit.updateSeekPosition(Duration(seconds: value.toInt()));
            }
          : null,
      onChangeEnd: cubit.songDuration.inSeconds > 0
          ? (value) {
              cubit.seekTo(Duration(seconds: value.toInt()));
            }
          : null,
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}