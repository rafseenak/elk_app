// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

loadingDialog(BuildContext context, {bool dismisaable = false}) => showDialog(
    useSafeArea: false,
    barrierColor: Colors.black26,
    barrierDismissible: false,
    context: context,
    builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarColor: Colors.transparent),
          child: WillPopScope(
            onWillPop: () async {
              return dismisaable;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Center(
                  child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.red)),
              )),
            ),
          ),
        ));
