// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'user_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserContact _$UserContactFromJson(Map<String, dynamic> json) => UserContact(
      name: json['name'] as String?,
      mobile: json['mobile_number'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserContactToJson(UserContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mobile_number': instance.mobile,
      'email': instance.email,
    };
