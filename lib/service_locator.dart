import 'package:get_it/get_it.dart';
import 'package:spotify/data/repository/auth/auth_repository_imp.dart';
import 'package:spotify/data/repository/song/song_repository_imp.dart';
import 'package:spotify/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify/data/sources/song/song_firebase_service.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/domain/repository/song/song_repository.dart';
import 'package:spotify/domain/usecases/get_Latest_Song.dart';
import 'package:spotify/domain/usecases/get_play_List.dart';
import 'package:spotify/domain/usecases/signin.dart';
import 'package:spotify/domain/usecases/signup.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImp());
  sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImp());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());
  sl.registerSingleton<SongRepository>(SongRepositoryImp());

  sl.registerSingleton<SignUpUseCase>(SignUpUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
  sl.registerSingleton<GetLatestSongUseCse>(GetLatestSongUseCse());
  sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());
}
