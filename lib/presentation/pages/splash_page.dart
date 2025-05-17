import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/core/configs/assets/app_vectors.dart';
import 'package:spotify/presentation/pages/get_started_page.dart';
import 'package:spotify/presentation/pages/home_page.dart'; 

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgPicture.asset(AppVectors.logo)),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), 
      );
    } else {
      // User not signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetStartedPage()),
      );
    }
  }
}
