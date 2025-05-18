import 'package:dartz/dartz.dart';
import 'package:spotify/data/sources/song/song_firebase_service.dart';
import 'package:spotify/domain/repository/song/song_repository.dart';
import 'package:spotify/service_locator.dart';

class SongRepositoryImp extends SongRepository {
  @override
  Future<Either> getLatestSongs() async{
    return await sl<SongFirebaseService>().getLatestSongs();
  }
  
  @override
  Future<Either> getPlayList() async {
    return await sl<SongFirebaseService>().getPlayList();
  }
}
