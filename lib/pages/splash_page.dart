import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_email/blocs/sign_in_bloc.dart';
import 'package:login_email/pages/home_page.dart';
import 'package:login_email/pages/sign_in_page.dart';
import 'package:login_email/utils/next_screen.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  afterSplash() {
    final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      sb.isSignedIn == true ? gotoHomePage() : gotoSignInPage();
    });
  }

  gotoHomePage() {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
    }
    nextScreenReplace(context, const HomePage());
  }

  gotoSignInPage() {
    nextScreenReplace(context, const SignInPage());
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    afterSplash();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FadeTransition(
        opacity: animation,
        child: const Image(
          image: AssetImage("assets/logo.png"),
          height: 220,
          width: 220,
          fit: BoxFit.contain,
        ),
      )),
    );
  }
}
