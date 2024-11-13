import 'package:flutter/material.dart';

Container commonButton(String text,
        {bool enabled = true,
        required onTap,
        double? height,
        EdgeInsetsGeometry? margin,
        EdgeInsetsGeometry? padding}) =>
    Container(
      margin: margin ?? const EdgeInsets.only(top: 20),
      width: double.infinity,
      height: height ?? 40,
      child: FilledButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.amber),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
