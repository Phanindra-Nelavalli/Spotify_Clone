import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/data/models/auth/signin_user_req.dart';
import 'package:spotify/data/models/auth/user.dart';
import 'package:spotify/domain/entities/auth/user.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq siginUserReq);
  Future<Either> getUser();
}

class AuthFirebaseServiceImp extends AuthFirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
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
      var data = await auth.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );
      await db.collection("Users").doc(data.user!.uid).set({
        "name": createUserReq.fullName,
        "email": createUserReq.email,
      });
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

  @override
  Future<Either> getUser() async {
    try {
      var user = await db.collection("Users").doc(auth.currentUser!.uid).get();
      UserModel userModel = UserModel.fromJSON(user.data()!);
      userModel.imageURL = auth.currentUser?.photoURL;
      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return Left("An error occured");
    }
  }
}
