import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/bloc/song_player_state.dart';

class SongPlayerPage extends StatelessWidget {
  final SongEntity song;
  const SongPlayerPage({super.key, required this.song});

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
                ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              _songCover(song, context),
              SizedBox(height: 17),
              _songDetails(song),
              SizedBox(height: 20),
              _songPlayer(),
            ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              song.artist,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.favorite_outline_rounded,
            color: AppColors.darkGrey,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget _songPlayer() {
    return BlocBuilder<SongPlayerCubit,SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoaded) {
          return Column(
            children: [
              Slider(
                activeColor: AppColors.primary,
                value:
                    context
                        .read<SongPlayerCubit>()
                        .songPosition
                        .inSeconds
                        .toDouble(),
                min: 0.0,
                max:
                    context
                        .read<SongPlayerCubit>()
                        .songDuration
                        .inSeconds
                        .toDouble(),
                onChanged: (value) {},
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
}
