// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';

class StringConstants {
  static const imageAssetsPath = 'assets/images';
  static const iconAssetPath = 'assets/category_icons';
  static const svgAssetsPath = 'assets/svg';
  static const _testApiAddress = 'http://192.168.1.5:3000/api/';
  static const _nodeTestAddress = 'https://backend-elk.onrender.com/api/';
  static const apiAddress = "https://api.elkcompany.online/api/";
  static const _railwayApiAddress =
      'https://backend-elk-production.up.railway.app/api/';
  static const _baseApiAddress = 'https://elkcompany.in/api/';
  static const baseUrl = kReleaseMode ? apiAddress : apiAddress;

  static const publicUrl =
      kReleaseMode ? 'https://elkcompany.in/' : 'http://192.168.188.96:8000/';
}
