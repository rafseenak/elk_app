// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'place_entity.g.dart';

@JsonSerializable()
class PlaceSimple {
  final String value;
  final double latitude;
  final double longitude;
  final int count;

  PlaceSimple(
      {required this.value,
      required this.latitude,
      required this.longitude,
      required this.count});

  factory PlaceSimple.fromJson(Map<String, dynamic> json) =>
      _$PlaceSimpleFromJson(json);
}
