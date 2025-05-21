import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/get_user.dart';
import 'package:spotify/presentation/bloc/profile_info_state.dart';
import 'package:spotify/service_locator.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit() : super(ProfileInfoLoading());

  Future<void> getUser() async {
    var user = await sl<GetUserUseCase>().call();

    user.fold(
      (l) {
        emit(ProfileInfoLoadingfailure());
      },
      (userEntity) {
        emit(ProfileInfoLoaded(userEntity: userEntity));
      },
    );
  }
}
