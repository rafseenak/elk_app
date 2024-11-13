// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:elk/data/model/location.dart';
import 'package:elk/utils/app_preferences.dart';

class LocationRepository {
  Future<void> setLocationAddes(Location location) async {
    await AppPrefrences.setLocation(location);
  }

  Future<Location?> getLocation() async {
    String? _ = await AppPrefrences.isLocationAdded();
    final __ = _ != null ? Location.fromJson(jsonDecode(_)) : null;
    return __;
  }
}
