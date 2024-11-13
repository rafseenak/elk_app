// ignore_for_file: unnecessary_import

import 'package:elk/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Row dividerText(String text) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
            child: Divider(
          color: dividerColor,
        )),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Expanded(
            child: Divider(
          color: dividerColor,
        ))
      ],
    );
