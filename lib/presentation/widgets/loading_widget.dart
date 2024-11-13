import 'package:flutter/material.dart';

class LoadinWidget extends StatelessWidget {
  const LoadinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
