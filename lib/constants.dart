import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants {
  //Strings
  static const appName = 'Elk';
  static const rupeeSymbol = '₹';
  static const indexUrl = kReleaseMode ? 'http://elkapp.eu-north-1.elasticbeanstalk.com/' : 'http://192.168.125.96:8000/';
  static const termsUrl = '${indexUrl}terms_privacy';

  //Colros
  static const primaryColor =
      Color(0xFF4Fbbb4); //Color.fromRGBO(255, 218, 63, 1);
  static const accentColor = Color(0xFFFFDA3f);
}
