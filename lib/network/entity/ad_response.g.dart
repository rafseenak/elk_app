// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'ad_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdResponse _$AdResponseFromJson(Map<String, dynamic> json) => AdResponse(
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
      distance: (json['distance'] as num?)?.toDouble(),
      wishListed: json['wishListed'] as bool?,
      adWishlistsCount: json['ad_wish_lists_count'] as int?,
      adViewsCount: json['ad_views_count'] as int?,
      user: json['user'] == null
          ? null
          : UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      adImages: (json['ad_images'] as List<dynamic>)
          .map((e) => AdImageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      adPriceDetails: (json['ad_price_details'] as List<dynamic>)
          .map((e) => AdPriceDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      adLocation: json['ad_location'] == null
          ? null
          : AdLocationResponse.fromJson(
              json['ad_location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdResponseToJson(AdResponse instance) =>
    <String, dynamic>{
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
      'distance': instance.distance,
      'user': instance.user,
      'wishListed': instance.wishListed,
      'ad_wish_lists_count': instance.adWishlistsCount,
      'ad_views_count': instance.adViewsCount,
      'ad_images': instance.adImages,
      'ad_price_details': instance.adPriceDetails,
      'ad_location': instance.adLocation,
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      profile: json['profile'] as String?,
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'email': instance.email,
      'mobile_number': instance.mobileNumber,
      'profile': instance.profile,
    };

AdImageResponse _$AdImageResponseFromJson(Map<String, dynamic> json) =>
    AdImageResponse(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      image: json['image'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdImageResponseToJson(AdImageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'image': instance.image,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

AdPriceDetailResponse _$AdPriceDetailResponseFromJson(
        Map<String, dynamic> json) =>
    AdPriceDetailResponse(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      rentDuration: json['rent_duration'] as String,
      rentPrice: json['rent_price'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdPriceDetailResponseToJson(
        AdPriceDetailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'rent_duration': instance.rentDuration,
      'rent_price': instance.rentPrice,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

AdLocationResponse _$AdLocationResponseFromJson(Map<String, dynamic> json) =>
    AdLocationResponse(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      country: json['country'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      locality: json['locality'] as String?,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AdLocationResponseToJson(AdLocationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_id': instance.adId,
      'country': instance.country,
      'state': instance.state,
      'city': instance.district,
      'locality': instance.locality,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
