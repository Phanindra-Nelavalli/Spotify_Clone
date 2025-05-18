import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/bloc/latest_song_cubit.dart';
import 'package:spotify/presentation/bloc/latest_song_state.dart';

class LatestSongs extends StatelessWidget {
  const LatestSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LatestSongCubit()..getLatestSongs(),
      child: SizedBox(
        height: 200,
        child: BlocBuilder<LatestSongCubit, LatestSongState>(
          builder: (context, state) {
            if (state is LatestSongLoading) {
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is LatestSongLoaded) {
              return _songs(state.songs);
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "${AppUrls.firestorage}${Uri.encodeComponent('${song.artist} - ${song.title}.jpg')}?${AppUrls.mediaAlt}",
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 40,
                    width: 40,
                    transform: Matrix4.translationValues(10, 10, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDarkMode? AppColors.darkGrey:Color(0xffe6e6e6e),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: context.isDarkMode? Color(0xff959595):Color(0xff555555),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 13),
            Text(
              song.title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              song.title,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(width: 16);
      },
      itemCount: songs.length,
    );
  }
}
