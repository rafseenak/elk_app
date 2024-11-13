// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'place_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSearch _$PlaceSearchFromJson(Map<String, dynamic> json) => PlaceSearch(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: json['type'] as String,
      locality: json['locality'] as String?,
      place: json['place'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlaceSearchToJson(PlaceSearch instance) =>
    <String, dynamic>{
      'type': instance.type,
      'locality': instance.locality,
      'place': instance.place,
      'district': instance.district,
      'state': instance.state,
      'country': instance.country,
      'distance': instance.distance,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
