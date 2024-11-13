// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:flutter/material.dart';

Container borderButton(
  String text, {
  required onTap,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  bool enabled = false,
}) =>
    Container(
      margin: margin ?? const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: enabled ? Colors.black : Colors.grey),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(text),
      ),
    );
