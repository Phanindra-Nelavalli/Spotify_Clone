import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/get_Latest_Song.dart';
import 'package:spotify/presentation/bloc/latest_song_state.dart';
import 'package:spotify/service_locator.dart';

class LatestSongCubit extends Cubit<LatestSongState> {
  LatestSongCubit() : super(LatestSongLoading());

  Future<void> getLatestSongs() async {
    emit(LatestSongLoading()); // emit loading state

    var resultedSongs = await sl<GetLatestSongUseCse>().call();

    resultedSongs.fold(
      (l) {
        print("Error fetching latest songs: $l");
        emit(LatestSongLoadingFailure());
      },
      (data) {
        emit(LatestSongLoaded(songs: data));
      },
    );
  }
}
