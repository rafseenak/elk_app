// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      type: json['type'] as String?,
      locality: json['locality'] as String?,
      place: json['place'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'type': instance.type,
      'locality': instance.locality,
      'place': instance.place,
      'district': instance.district,
      'state': instance.state,
      'country': instance.country,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'distance': instance.distance,
    };
