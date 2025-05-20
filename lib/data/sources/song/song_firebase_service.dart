import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/song/song_model.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/domain/usecases/is_favorite_song.dart';
import 'package:spotify/service_locator.dart';

abstract class SongFirebaseService {
  Future<Either> getLatestSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavouriteSong(String songId);
  Future<bool> isFavouriteSong(String songId);
}

class SongFirebaseServiceImp extends SongFirebaseService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
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
        bool isFavourite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavourite = isFavourite;
        songModel.songId = element.reference.id;
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
        bool isFavourite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavourite = isFavourite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }
      return Right(songs);
    } catch (e) {
      print(e);
      return Left("Error Occured");
    }
  }

  @override
  Future<Either> addOrRemoveFavouriteSong(String songId) async {
    try {
      String userId = auth.currentUser!.uid;
      late bool isFavourite;
      QuerySnapshot favouriteSongs =
          await db
              .collection('Users')
              .doc(userId)
              .collection('Favourites')
              .where('songId', isEqualTo: songId)
              .get();
      if (favouriteSongs.docs.isNotEmpty) {
        await favouriteSongs.docs.first.reference.delete();
        isFavourite = false;
      } else {
        await db.collection('Users').doc(userId).collection('Favourites').add({
          'songId': songId,
          'addedTime': Timestamp.now(),
        });
        isFavourite = true;
      }

      return Right(isFavourite);
    } catch (e) {
      return Left("An error occured");
    }
  }

  @override
  Future<bool> isFavouriteSong(String songId) async {
    try {
      String userId = auth.currentUser!.uid;
      QuerySnapshot favouriteSongs =
          await db
              .collection('Users')
              .doc(userId)
              .collection('Favourites')
              .where('songId', isEqualTo: songId)
              .get();
      if (favouriteSongs.docs.isNotEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
