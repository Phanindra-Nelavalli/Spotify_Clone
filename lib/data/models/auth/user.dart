import 'package:spotify/domain/entities/auth/user.dart';

class UserModel {
  String? fullName;
  String? email;
  String? imageURL;

  UserModel({this.imageURL, this.fullName, this.email});
  UserModel.fromJSON(Map<String, dynamic> data) {
    fullName = data['name'];
    email = data['email'];

  }
}

extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      fullName: fullName!,
      email: email!
    );
  }
}
