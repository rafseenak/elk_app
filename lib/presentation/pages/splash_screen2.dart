import 'package:elk/bloc/splash/splash_bloc.dart';
import 'package:elk/presentation/pages/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashStart()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashFinished) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (ctx1) => const DashBoardScreen(),
              ),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/splash.jpeg',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: 80,
                right: 80,
                child: Animate(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ).animate().fade(duration: 500.ms).scale(delay: 500.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
