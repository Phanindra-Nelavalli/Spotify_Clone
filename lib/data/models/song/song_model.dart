import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify/domain/entities/song/song.dart';

class SongModel {
  String? title;
  String? artist;
  num? duration;
  Timestamp? releaseDate;
  bool? isFavourite;
  String? songId;

  SongModel({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.isFavourite,
    required this.songId
  });

  SongModel.fromJSON(Map<String, dynamic> data) {
    title = data['title'];
    artist = data['artist'];
    duration = data['duration'];
    releaseDate = data['releaseDate'];
  }
}

extension SongModelX on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title!,
      artist: artist!,
      duration: duration!,
      releaseDate: releaseDate!,
      isFavourite: isFavourite!,
      songId: songId!
    );
  }
}
