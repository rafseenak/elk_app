import 'package:elk/constants/stringss.dart';
import 'package:flutter/material.dart';

class ErrorScreenWidget extends StatelessWidget {
  final String error;
  final Function()? onTap;
  const ErrorScreenWidget(this.error, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('${StringConstants.imageAssetsPath}/error.png', width: 200,),
            const SizedBox(height: 10,),
            Text(error),
            button(onTap == null ? 'Go back' : 'Retry', () {
              if (onTap != null) {
                onTap;
              } else {
                Navigator.pop(context);
              }
            })
          ],
        ),
      ),
    );
  }

  Widget button(String label, Function() onTap) {
    return TextButton(onPressed: onTap, child: Text(label));
  }
}
