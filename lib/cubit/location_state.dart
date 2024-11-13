// ignore_for_file: unused_import

import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/network/entity/place.dart';
import 'package:elk/network/entity/place_search.dart';

abstract class LocationState {}

class LocationInitialState extends LocationState {}

class LocationLoadState extends LocationState {
  final Location location;
  LocationLoadState({required this.location});
}
