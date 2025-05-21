import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:spotify/common/widgets/favourite_button.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/bloc/favourite_song_cubit.dart';
import 'package:spotify/presentation/bloc/favourite_song_state.dart';
import 'package:spotify/presentation/bloc/profile_info_cubit.dart';
import 'package:spotify/presentation/bloc/profile_info_state.dart';
import 'package:spotify/presentation/pages/song_player_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Scaffold(
        appBar: BasicAppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff2C2B2B),
          action: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 29),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _profileInfo(context),
              SizedBox(height: 20),
              _favouriteSongs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
        builder: (context, state) {
          if (state is ProfileInfoLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileInfoLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        state.userEntity.imageURL ?? AppUrls.defaultImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(state.userEntity.email!),
                const SizedBox(height: 10),
                Text(
                  state.userEntity.fullName!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ],
            );
          }
          if (state is ProfileInfoLoadingfailure) {
            return const Center(child: Text("Please try again rlater"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _favouriteSongs() {
    return BlocProvider(
      create: (_) => FavouriteSongCubit()..getFavouriteSongs(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FAVOURITE SONGS"),
            BlocBuilder<FavouriteSongCubit, FavouriteSongsState>(
              builder: (context, state) {
                if (state is FavouriteSongsLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is FavouriteSongsLoaded) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        SongEntity song = state.favouriteSongs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        SongPlayerPage(song: song),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          "${AppUrls.firestorage}${Uri.encodeComponent('${song.artist} - ${song.title}.jpg')}?${AppUrls.mediaAlt}",
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        song.artist,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    song.duration
                                        .toStringAsFixed(2)
                                        .replaceAll('.', ':'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  FavouriteButton(
                                    songEntity: song,
                                    size: 30,
                                    function: () {
                                      context
                                          .read<FavouriteSongCubit>()
                                          .removeSong(index);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) => SizedBox(height: 20),
                      itemCount: state.favouriteSongs.length,
                    ),
                  );
                }
                if (state is FavouriteSongsLoadingFailure) {
                  return Text("Please try again later");
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
