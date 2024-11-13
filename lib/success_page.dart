import 'package:elk/provider/auth_provider.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class TestSuccessPage extends StatelessWidget {
  const TestSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SUCCESS!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AppPrefrences.clearUser().then((value) {
                  Fluttertoast.showToast(msg: 'Signout successfully');
                  context.read<AppAuthProvider>().isSignedIn();
                });
              },
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
