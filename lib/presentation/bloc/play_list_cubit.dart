import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/get_play_List.dart';
import 'package:spotify/presentation/bloc/play_list_state.dart';
import 'package:spotify/service_locator.dart';

class PlayListCubit extends Cubit<PlayListState> {
  PlayListCubit() : super(PlayListLoading());

  Future<void> getPlayList() async {
    emit(PlayListLoading()); // emit loading state

    var resultedSongs = await sl<GetPlayListUseCase>().call();

    resultedSongs.fold(
      (l) {
        print("Error fetching latest songs: $l");
        emit(PlayListLoadingFailure());
      },
      (data) {
        emit(PlayListLoaded(songs: data));
      },
    );
  }
}
