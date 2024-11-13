import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String error;
  const EmptyList(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '${StringConstants.imageAssetsPath}/empty_box.png',
              width: 150,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(error),
            button('Go back', () {
              Navigator.pop(context);
            }, canGoBack)
          ],
        ),
      ),
    );
  }

  Widget button(String label, Function() onTap, bool canGoBack) => canGoBack
      ? TextButton(
          onPressed: onTap,
          style: const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Constants.primaryColor),
          ),
          child: Text(label),
        )
      : const SizedBox();
}
