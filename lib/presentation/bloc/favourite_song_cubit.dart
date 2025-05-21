import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/domain/usecases/get_favourite_songs.dart';
import 'package:spotify/presentation/bloc/favourite_song_state.dart';
import 'package:spotify/service_locator.dart';

class FavouriteSongCubit extends Cubit<FavouriteSongsState> {
  FavouriteSongCubit() : super(FavouriteSongsLoading());

  List<SongEntity> favouriteSongs = [];

  Future<void> getFavouriteSongs() async {
    var result = await sl<GetFavouriteSongsUseCase>().call();
    result.fold(
      (l) {
        emit(FavouriteSongsLoadingFailure());
      },
      (r) {
        favouriteSongs = r;
        emit(FavouriteSongsLoaded(favouriteSongs: favouriteSongs));
      },
    );
  }

  void removeSong(int index) {
    favouriteSongs.removeAt(index);
    emit(FavouriteSongsLoaded(favouriteSongs: favouriteSongs));
  }
}
