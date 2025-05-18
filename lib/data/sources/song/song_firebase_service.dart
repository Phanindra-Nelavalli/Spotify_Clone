import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:spotify/data/models/song/song_model.dart';
import 'package:spotify/domain/entities/song/song.dart';

abstract class SongFirebaseService {
  Future<Either> getLatestSongs();
  Future<Either> getPlayList();
}

class SongFirebaseServiceImp extends SongFirebaseService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Future<Either> getLatestSongs() async {
    List<SongEntity> songs = [];
    try {
      var data =
          await db
              .collection('Songs')
              .orderBy('releaseDate', descending: true)
              .limit(3)
              .get();
      for (var element in data.docs) {
        var songModel = SongModel.fromJSON(element.data());
        songs.add(songModel.toEntity());
      }
      return Right(songs);
    } catch (e) {
      print(e);
      return Left("Error Occured");
    }
  }

  @override
  Future<Either> getPlayList() async {
    List<SongEntity> songs = [];
    try {
      var data =
          await db
              .collection('Songs')
              .orderBy('releaseDate', descending: true)
              .get();
      for (var element in data.docs) {
        var songModel = SongModel.fromJSON(element.data());
        songs.add(songModel.toEntity());
      }
      return Right(songs);
    } catch (e) {
      print(e);
      return Left("Error Occured");
    }
  }
}
