// ignore_for_file: unused_import

import 'package:elk/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileCompleteDialog extends StatelessWidget {
  const ProfileCompleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    AppAuthProvider authProvider =
        Provider.of<AppAuthProvider>(context, listen: false);
    // bool nameIsNull = authProvider.authUser!.name == null ||
    //     authProvider.authUser!.name == 'User' ||
    //     authProvider.authUser!.name == '';
    bool emailIsNull = authProvider.authUser!.email == null ||
        authProvider.authUser!.email == '';
    bool mobileIsNull = authProvider.authUser!.mobile == null ||
        authProvider.authUser!.mobile == '';
    String title =
        '''Please update your ${mobileIsNull && emailIsNull ? 'mobile, and email' : 'name'}''';
    // String title =
    //     '''Please update your ${nameIsNull && emailIsNull ? 'name, and email' : nameIsNull && mobileIsNull ? 'name and mobile number' : emailIsNull ? 'email' : mobileIsNull ? 'mobile number' : 'name'}''';

    return AlertDialog(
      title: Text('Profile update required',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith()),
      content: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
      ),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Close')),
        TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Continue'))
      ],
    );
  }
}
