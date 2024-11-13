// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'ad_response.g.dart';

class AdRes {
  final int total;
  final int? to;
  final List<AdResponse> adResponses;

  AdRes({required this.total, required this.to, required this.adResponses});

  factory AdRes.fromJson(Map<String, dynamic> json) {
    return AdRes(
        total: json['total'],
        to: json['to'],
        adResponses: (json['data'] as List<dynamic>)
            .map((e) => AdResponse.fromJson(e as Map<String, dynamic>))
            .toList());
  }
}

@JsonSerializable()
class AdResponse {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  @JsonKey(name: 'user_id')
  int userId;
  String title;
  String category;
  String description;
  @JsonKey(name: 'ad_type')
  String adType;
  @JsonKey(name: 'ad_status')
  String adStatus;
  @JsonKey(name: 'ad_stage')
  int adStage;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;
  double? distance;
  UserResponse? user;
  bool? wishListed;
  @JsonKey(name: 'ad_wish_lists_count')
  int? adWishlistsCount;
  @JsonKey(name: 'ad_views_count')
  int? adViewsCount;
  @JsonKey(name: 'ad_images')
  List<AdImageResponse> adImages;
  @JsonKey(name: 'ad_price_details')
  List<AdPriceDetailResponse> adPriceDetails;
  @JsonKey(name: 'ad_location')
  AdLocationResponse? adLocation;

  AdResponse({
    required this.id,
    required this.adId,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.adType,
    required this.adStatus,
    required this.adStage,
    required this.createdAt,
    required this.updatedAt,
    required this.distance,
    required this.wishListed,
    required this.adWishlistsCount,
    required this.adViewsCount,
    required this.user,
    required this.adImages,
    required this.adPriceDetails,
    required this.adLocation,
  });

  factory AdResponse.fromJson(Map<String, dynamic> json) =>
      _$AdResponseFromJson(json);
}

@JsonSerializable()
class UserResponse {
  int id;
  @JsonKey(name: 'user_id')
  int userId;
  String name;
  String? description;
  String? email;
  @JsonKey(name: 'mobile_number')
  String? mobileNumber;
  String? profile;

  UserResponse({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.email,
    required this.mobileNumber,
    required this.profile,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

@JsonSerializable()
class AdImageResponse {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  String image;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;

  AdImageResponse({
    required this.id,
    required this.adId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdImageResponse.fromJson(Map<String, dynamic> json) =>
      _$AdImageResponseFromJson(json);
}

@JsonSerializable()
class AdPriceDetailResponse {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  @JsonKey(name: 'rent_duration')
  String rentDuration;
  @JsonKey(name: 'rent_price')
  String rentPrice;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;

  AdPriceDetailResponse({
    required this.id,
    required this.adId,
    required this.rentDuration,
    required this.rentPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdPriceDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$AdPriceDetailResponseFromJson(json);
}

@JsonSerializable()
class AdLocationResponse {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  String country;
  String state;
  String district;
  String? locality;
  String longitude;
  String latitude;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;

  AdLocationResponse({
    required this.id,
    required this.adId,
    required this.country,
    required this.state,
    required this.district,
    required this.locality,
    required this.longitude,
    required this.latitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$AdLocationResponseFromJson(json);
}
