import 'package:elk/data/enum/location_type.dart';
import 'package:elk/network/entity/place.dart';
import 'package:elk/network/entity/place_search.dart';

class Location {
  final LocationType locationType;
  final double latitude;
  final double longitude;
  String? locality;
  String? place;
  String? district;
  String? state;
  String country;

  Location({
    required this.locationType,
    this.locality,
    this.place,
    this.district,
    this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        locationType: json['type'] == 'locality'
            ? LocationType.locality
            : json['type'] == 'place'
                ? LocationType.place
                : json['type'] == 'district'
                    ? LocationType.district
                    : json['type'] == 'state'
                        ? LocationType.state
                        : LocationType.country,
        latitude: json['latitude'],
        longitude: json['longitude'],
        country: json['country'],
        state: json['state'],
        district: json['district'],
        place: json['place'],
        locality: json['locality']);
  }
  factory Location.fromPlace(Place place) {
    return Location(
        locationType: place.type == 'locality'
            ? LocationType.locality
            : place.type == 'place'
                ? LocationType.place
                : place.type == 'district'
                    ? LocationType.district
                    : place.state == 'state'
                        ? LocationType.state
                        : LocationType.country,
        latitude: place.latitude,
        longitude: place.longitude,
        country: place.country,
        state: place.state,
        district: place.district,
        place: place.place,
        locality: place.locality);
  }
  factory Location.fromPlaceSearch(PlaceSearch place) {
    return Location(
        locationType: place.type == 'locality'
            ? LocationType.locality
            : place.type == 'place'
                ? LocationType.place
                : place.type == 'district'
                    ? LocationType.district
                    : place.state == 'state'
                        ? LocationType.state
                        : LocationType.country,
        latitude: place.latitude,
        longitude: place.longitude,
        country: place.country,
        state: place.state,
        district: place.district,
        place: place.place,
        locality: place.locality);
  }
}
