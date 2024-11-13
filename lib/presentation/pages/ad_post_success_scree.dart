// ignore_for_file: unnecessary_import

import 'package:elk/config/routes_constants.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:lottie/lottie.dart';

class AdPostSuccessScreen extends StatelessWidget {
  final bool fromEdit;
  final int adId;

  const AdPostSuccessScreen(this.fromEdit, this.adId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: SizedBox(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: SizedBox(
                width: 200,
                height: 200,
                child:
                    Lottie.asset('assets/lottie/success.json', repeat: false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: Text(
                localisation(context).adPostSuccess,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Text(localisation(context).conTinue),
                onPressed: () {
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(),
              child: FilledButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.amber),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                child: Text(localisation(context).preview),
                onPressed: () {
                  Navigator.pushNamed(context, RouteConstants.previewPost,
                      arguments: adId);
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
