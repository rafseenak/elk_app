// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'place_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSimple _$PlaceSimpleFromJson(Map<String, dynamic> json) => PlaceSimple(
      value: json['value'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      count: json['count'] as int,
    );

Map<String, dynamic> _$PlaceSimpleToJson(PlaceSimple instance) =>
    <String, dynamic>{
      'value': instance.value,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'count': instance.count,
    };
