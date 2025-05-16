import 'package:get_it/get_it.dart';
import 'package:spotify/data/repository/auth/auth_repository_imp.dart';
import 'package:spotify/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/domain/usecases/signin.dart';
import 'package:spotify/domain/usecases/signup.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImp());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
}
