// lib/common/widgets/favourite_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/bloc/favourite_button_cubit.dart';
import 'package:spotify/common/bloc/favourite_button_state.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';

class FavouriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final double size;
  final Function? function;

  const FavouriteButton({
    super.key,
    required this.songEntity,
    required this.size,
    this.function,
  });

  @override
  Widget build(BuildContext context) {
    // Access the shared FavouriteButtonCubit
    final favouriteButtonCubit = BlocProvider.of<FavouriteButtonCubit>(context);

    // Initialize the song status when the button is built
    favouriteButtonCubit.initSongStatus(
      songEntity.songId,
      songEntity.isFavourite,
    );

    return BlocBuilder<FavouriteButtonCubit, FavouriteButtonState>(
      builder: (context, state) {
        bool isFavourite;

        if (state is FavouriteButtonUpdated &&
            state.songId == songEntity.songId) {
          isFavourite = state.isFavourite;
        } else {
          isFavourite = favouriteButtonCubit.isSongFavourite(songEntity.songId);
        }

        return IconButton(
          onPressed: () async{
            favouriteButtonCubit.favouriteButtonUpdated(songEntity.songId);
            if (function != null) {
              function!();
            }
          },
          icon: Icon(
            isFavourite
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            color: AppColors.darkGrey,
            size: size,
          ),
        );
      },
    );
  }
}
