// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'ad_user.g.dart';

@JsonSerializable()
class AdUser {
  int id;
  @JsonKey(name: 'user_id')
  int userId;
  String? name;
  String? profile;
  String? description;
  List<Ad> ads;

  AdUser({
    required this.id,
    required this.userId,
    required this.name,
    required this.profile,
    required this.description,
    required this.ads,
  });

  factory AdUser.fromJson(Map<String, dynamic> json) => _$AdUserFromJson(json);
}

@JsonSerializable()
class Ad {
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
  @JsonKey(name: 'ad_price_details')
  List<AdPriceDetail> adPriceDetails;
  @JsonKey(name: 'ad_images')
  List<AdImage> adImages;
  @JsonKey(name: 'ad_location')
  AdLocation adLocation;

  Ad({
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
    required this.adPriceDetails,
    required this.adImages,
    required this.adLocation,
  });

  factory Ad.fromJson(Map<String, dynamic> json) => _$AdFromJson(json);
}

@JsonSerializable()
class AdPriceDetail {
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

  AdPriceDetail({
    required this.id,
    required this.adId,
    required this.rentDuration,
    required this.rentPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdPriceDetail.fromJson(Map<String, dynamic> json) =>
      _$AdPriceDetailFromJson(json);
}

@JsonSerializable()
class AdImage {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  String image;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;

  AdImage({
    required this.id,
    required this.adId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdImage.fromJson(Map<String, dynamic> json) =>
      _$AdImageFromJson(json);
}

@JsonSerializable()
class AdLocation {
  int id;
  @JsonKey(name: 'ad_id')
  int adId;
  String? country;
  String? state;
  String? city;
  String? locality;
  String longitude;
  String latitude;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;

  AdLocation({
    required this.id,
    required this.adId,
    required this.country,
    required this.state,
    required this.city,
    required this.locality,
    required this.longitude,
    required this.latitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdLocation.fromJson(Map<String, dynamic> json) =>
      _$AdLocationFromJson(json);
}
