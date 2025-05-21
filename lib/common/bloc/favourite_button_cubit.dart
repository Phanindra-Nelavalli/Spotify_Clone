import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/add_or_remove_favourite_song.dart';
import 'package:spotify/common/bloc/favourite_button_state.dart';
import 'package:spotify/service_locator.dart';

class FavouriteButtonCubit extends Cubit<FavouriteButtonState> {
  final Map<String, bool> _favouriteStatus = {};
  FavouriteButtonCubit() : super(FavoriteButtonInitial());
  void initSongStatus(String songId, bool isFavourite) {
    _favouriteStatus[songId] = isFavourite;
  }

  // Get current favorite status for a song
  bool isSongFavourite(String songId) {
    return _favouriteStatus[songId] ?? false;
  }

  void favouriteButtonUpdated(String songId) async {
    var result = await sl<AddOrRemoveFavouriteSongUseCase>().call(
      params: songId,
    );

    result.fold(
      (failure) {
        
      },
      (isFavourite) {
        // Update local cache
        _favouriteStatus[songId] = isFavourite;

        // Emit new state to notify all listeners
        emit(FavouriteButtonUpdated(songId: songId, isFavourite: isFavourite));
      },
    );
  }
}
