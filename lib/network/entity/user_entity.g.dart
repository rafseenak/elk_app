// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      name: json['name'] as String?,
      decription: json['description'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile_number'] as String?,
      profile: json['profile'] as String?,
      token: json['token'] as String?,
      userId: json['user_id'] as int?,
      isGuest: json['is_guest'],
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'decription': instance.decription,
      'email': instance.email,
      'mobile_number': instance.mobile,
      'profile': instance.profile,
      'token': instance.token,
      'user_id': instance.userId,
      'is_guest': instance.isGuest
    };
