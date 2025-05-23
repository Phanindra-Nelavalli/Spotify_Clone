import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        create:
            (_) =>
                SongPlayerCubit()..loadSong(
                  "${AppUrls.songFirestorage}${Uri.encodeComponent('${song.artist} - ${song.title}.mp3')}?${AppUrls.mediaAlt}",
                  songPlaylist: playlist,
                  initialIndex: initialIndex,
                ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: BlocBuilder<SongPlayerCubit, SongPlayerState>(
            builder: (context, state) {
              final cubit = context.read<SongPlayerCubit>();
              final currentSong = cubit.currentSong ?? song;

              return Column(
                children: [
                  _songCover(currentSong, context),
                  SizedBox(height: 17),
                  _songDetails(currentSong),
                  SizedBox(height: 20),
                  _songPlayer(),
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
              ),
              SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        FavouriteButton(songEntity: song, size: 35),
      ],
    );
  }

  Widget _songPlayer() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoaded) {
          final cubit = context.read<SongPlayerCubit>();

          return Column(
            children: [
              // Progress Slider
              Slider(
                activeColor: AppColors.primary,
                value: cubit.songPosition.inSeconds.toDouble(),
                min: 0.0,
                max: cubit.songDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  cubit.updateSeekPosition(Duration(seconds: value.toInt()));
                },
                onChangeEnd: (value) {
                  cubit.seekTo(Duration(seconds: value.toInt()));
                },
              ),

              // Time Display
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(cubit.songPosition)),
                  Text(formatDuration(cubit.songDuration)),
                ],
              ),

              // Control Buttons Row
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle Button
                  GestureDetector(
                    onTap: () => cubit.toggleShuffle(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            cubit.isShuffleEnabled
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.transparent,
                      ),
                      child: Icon(
                        Icons.shuffle,
                        size: 24,
                        color:
                            cubit.isShuffleEnabled
                                ? AppColors.primary
                                : Colors.grey,
                      ),
                    ),
                  ),

                  // Previous Button
                  GestureDetector(
                    onTap:
                        cubit.playlist.isNotEmpty
                            ? () => cubit.playPreviousSong()
                            : null,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.skip_previous_rounded,
                        size: 32,
                        color:
                            cubit.playlist.isNotEmpty
                                ? Colors.white
                                : Colors.grey,
                      ),
                    ),
                  ),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () => cubit.playOrPause(),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
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
                  GestureDetector(
                    onTap:
                        cubit.playlist.isNotEmpty
                            ? () => cubit.playNextSong()
                            : null,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.skip_next_rounded,
                        size: 32,
                        color:
                            cubit.playlist.isNotEmpty
                                ? Colors.white
                                : Colors.grey,
                      ),
                    ),
                  ),

                  // Repeat Button
                  GestureDetector(
                    onTap: () => cubit.toggleRepeat(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            cubit.repeatMode != LoopMode.off
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.transparent,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            cubit.repeatMode == LoopMode.one
                                ? Icons.repeat_one
                                : Icons.repeat,
                            size: 24,
                            color:
                                cubit.repeatMode != LoopMode.off
                                    ? AppColors.primary
                                    : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Optional: Display current playlist info
              if (cubit.playlist.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "${cubit.currentSongIndex + 1} of ${cubit.playlist.length}",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
            ],
          );
        }
        return Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}
