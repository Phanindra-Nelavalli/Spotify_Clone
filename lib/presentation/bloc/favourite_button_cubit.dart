import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/add_or_remove_favourite_song.dart';
import 'package:spotify/presentation/bloc/favourite_button_state.dart';
import 'package:spotify/service_locator.dart';

class FavouriteButtonCubit extends Cubit<FavouriteButtonState> {
  FavouriteButtonCubit() : super(FavoriteButtonInitial());

  void favouriteButtonUpdated(String songId) async {
    var result = await sl<AddOrRemoveFavouriteSongUseCase>().call(
      params: songId,
    );
    result.fold((l) {}, (r) {
      FavouriteButtonUpdated();
    });
  }
}
