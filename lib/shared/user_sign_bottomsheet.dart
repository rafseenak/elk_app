import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:flutter/material.dart';

class UserSignInSheet extends StatelessWidget {
  const UserSignInSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      child: Wrap(
        children: [
          Column(
            children: [
              Center(
                child: Image.asset(
                  '${StringConstants.imageAssetsPath}/locked.png',
                  width: 100,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "You don't have permission to access this option",
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Please sign in",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteConstants.login);
                  },
                  child: const Text(
                    "Sign in",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
