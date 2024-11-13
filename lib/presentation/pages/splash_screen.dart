// ignore_for_file: unused_import

import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/presentation/pages/language_selection_screen.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BodyState();
}

class _BodyState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? _fadeInFadeOut;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeInFadeOut =
        Tween<double>(begin: 1, end: 0.1).animate(animationController!);
    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController!.forward();
      }
    });
    animationController!.forward();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    Future.delayed(const Duration(seconds: 2), () async {
      authProvider.isSignedIn();
    });

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(80),
        child: Center(
          child: FadeTransition(
              opacity: _fadeInFadeOut!,
              child: Image.asset('assets/images/logo.png')),
        ),
      ),
    );
  }
}
