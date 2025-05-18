import 'package:dartz/dartz.dart';

abstract class SongRepository {
  Future<Either> getLatestSongs();
  Future<Either> getPlayList();
}
