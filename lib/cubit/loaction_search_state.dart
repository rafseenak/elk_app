// ignore_for_file: unused_import

import 'package:elk/network/entity/place_search.dart';
import 'package:elk/presentation/pages/location_search_screen.dart';

abstract class LocationSearchState {}

class InitialLocationSearchState extends LocationSearchState {}

class LoadPlacesDataState extends LocationSearchState {
  final bool addMoreAvailable;
  final List<PlaceSearch> currentData;
  LoadPlacesDataState(this.addMoreAvailable, this.currentData);
}
