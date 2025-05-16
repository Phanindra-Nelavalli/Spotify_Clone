import 'package:flutter/material.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/widgets/basic_app_button.dart';
import 'package:spotify/core/configs/assets/app_vectors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _registerText(context),
      appBar: BasicAppBar(
        title: SvgPicture.asset(AppVectors.logo, height: 35, width: 35),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signInText(),
              SizedBox(height: 20),
              _emailField(context),
              SizedBox(height: 20),
              _passwordField(context),
              SizedBox(height: 50),
              BasicAppButton(onPressed: () {}, title: "Create Account"),
              SizedBox(height: 40),
              _dividerrOr(),
              SizedBox(height: 35),
              _googleOrApple(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInText() {
    return Text(
      "Sign In",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Enter Email",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Password",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            size: 27,
          ),
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _dividerrOr() {
    return Row(
      children: [
        Expanded(child: Divider()),
        SizedBox(width: 10),
        Text("OR"),
        SizedBox(width: 10),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _googleOrApple() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppVectors.google, height: 40, width: 40),
          SizedBox(width: 58),
          SvgPicture.asset(
            context.isDarkMode ? AppVectors.appleDark : AppVectors.appleLight,
          ),
        ],
      ),
    );
  }

  Widget _registerText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Not a member?",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Register Now",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
