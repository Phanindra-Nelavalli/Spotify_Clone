import 'package:dartz/dartz.dart';
import 'package:spotify/core/usecases/usecase.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/service_locator.dart';

class GetUserUseCase extends UseCase<Either, dynamic> {
  @override
  Future<Either> call({params}) async {
    return sl<AuthRepository>().getUser();
  }
}
