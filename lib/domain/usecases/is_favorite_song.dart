import 'package:spotify/core/usecases/usecase.dart';
import 'package:spotify/domain/repository/song/song_repository.dart';
import 'package:spotify/service_locator.dart';

class IsFavoriteSongUseCase extends UseCase<bool, String> {
  @override
  Future<bool> call({String? params}) async {
    return await sl<SongRepository>().isFavouriteSong(params!);
  }
}
