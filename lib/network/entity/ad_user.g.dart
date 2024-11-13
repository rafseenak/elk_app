// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'ad_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdUser _$AdUserFromJson(Map<String, dynamic> json) => AdUser(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String?,
      profile: json['profile'] as String?,
      description: json['description'] as String?,
      ads: (json['ads'] as List<dynamic>)
          .map((e) => Ad.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdUserToJson(AdUser instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'profile': instance.profile,
      'description': instance.description,
      'ads': instance.ads,
    };

Ad _$AdFromJson(Map<String, dynamic> json) => Ad(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      adType: json['ad_type'] as String,
      adStatus: json['ad_status'] as String,
      adStage: json['ad_stage'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      adPriceDetails: (json['ad_price_details'] as List<dynamic>)
          .map((e) => AdPriceDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      adImages: (json['ad_images'] as List<dynamic>)
          .map((e) => AdImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      adLocation:
          AdLocation.fromJson(json['ad_location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdToJson(Ad instance) => <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'user_id': instance.userId,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'ad_type': instance.adType,
      'ad_status': instance.adStatus,
      'ad_stage': instance.adStage,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'ad_price_details': instance.adPriceDetails,
      'ad_images': instance.adImages,
      'ad_location': instance.adLocation,
    };

AdPriceDetail _$AdPriceDetailFromJson(Map<String, dynamic> json) =>
    AdPriceDetail(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      rentDuration: json['rent_duration'] as String,
      rentPrice: json['rent_price'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdPriceDetailToJson(AdPriceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'rent_duration': instance.rentDuration,
      'rent_price': instance.rentPrice,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

AdImage _$AdImageFromJson(Map<String, dynamic> json) => AdImage(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      image: json['image'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdImageToJson(AdImage instance) => <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'image': instance.image,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

AdLocation _$AdLocationFromJson(Map<String, dynamic> json) => AdLocation(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      locality: json['locality'] as String?,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdLocationToJson(AdLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'locality': instance.locality,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
