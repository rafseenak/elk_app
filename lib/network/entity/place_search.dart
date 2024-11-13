// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'place_search.g.dart';

@JsonSerializable()
class PlaceSearch {
  final String type;
  String? locality;
  String? place;
  String? district;
  String? state;
  String country;

  double? distance;
  final double latitude;
  final double longitude;
  PlaceSearch(
      {required this.latitude,
      required this.longitude,
      required this.type,
      this.locality,
      this.place,
      this.district,
      this.state,
      required this.country,
      this.distance});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) =>
      _$PlaceSearchFromJson(json);
}
