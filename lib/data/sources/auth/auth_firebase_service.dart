import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/data/models/auth/signin_user_req.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq siginUserReq);
}

class AuthFirebaseServiceImp extends AuthFirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Future<Either> signin(SigninUserReq siginUserReq) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: siginUserReq.email,
        password: siginUserReq.password,
      );

      return Right("SignIn was Successful");
    } on FirebaseAuthException catch (e) {
      print(e);
      String message = "";
      if (e.code == "invalid-email") {
        message = "User Not Found";
      } else if (e.code == "invali-credentials") {
        message = "Wrong Password";
      } else {
        message = "Authentication Error";
      }
      return Left(message);
    }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      return Right("SignUp was Successful");
    } on FirebaseAuthException catch (e) {
      print(e);
      String message = "";
      if (e.code == "weak-password") {
        message = "The password provided is too weak";
      } else if (e.code == "email-already-in-use") {
        message = "An account already exist with this email";
      } else {
        message = "Authentication Error";
      }
      return Left(message);
    }
  }
}
