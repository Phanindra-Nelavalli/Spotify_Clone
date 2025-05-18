import 'package:spotify/domain/entities/song/song.dart';

abstract class LatestSongState {}

class LatestSongLoading extends LatestSongState {}

class LatestSongLoaded extends LatestSongState {
  final List<SongEntity> songs;

  LatestSongLoaded({required this.songs});
}

class LatestSongLoadingFailure extends LatestSongState{}
