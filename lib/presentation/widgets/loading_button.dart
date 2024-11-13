// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:elk/constants.dart';
import 'package:flutter/material.dart';

Container loadingButton(
        {EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding}) =>
    Container(
        decoration: BoxDecoration(
            color: Constants.primaryColor,
            borderRadius: BorderRadius.circular(10)),
        width: double.infinity,
        child: const TextButton(
          onPressed: null,
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white)),
            ),
          ),
        ));
