abstract class FavouriteButtonState {}

class FavoriteButtonInitial extends FavouriteButtonState{}

class FavouriteButtonUpdated extends FavouriteButtonState{
  final String songId;
  final bool isFavourite;

  FavouriteButtonUpdated({required this.songId, required this.isFavourite});
}