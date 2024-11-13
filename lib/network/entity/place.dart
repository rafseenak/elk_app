// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'place.g.dart';

@JsonSerializable()
class Place {
  final String? type;
  final String? locality;
  final String? place;
  final String? district;
  final String? state;
  final String country;
  final double longitude;
  final double latitude;
  final double? distance;

  const Place(
      {required this.type,
      this.locality,
      this.place,
      this.district,
      this.state,
      required this.country,
      required this.longitude,
      required this.latitude,
      this.distance});

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
