import 'package:dartz/dartz.dart';
import 'package:spotify/core/usecases/usecase.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/service_locator.dart';

class SignUpUseCase extends UseCase<Either, CreateUserReq> {
  @override
  Future<Either> call({CreateUserReq? params}) async {
    return sl<AuthRepository>().signup(params!);
  }
}
