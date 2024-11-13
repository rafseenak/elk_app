// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity {
  final String? name;
  final String? decription;
  final bool isGuest;
  final String? email;
  @JsonKey(name: 'mobile_number')
  final String? mobile;
  final String? profile;
  final String? token;
  final int? userId;
  UserEntity({
    required this.name,
    required this.decription,
    required this.email,
    required this.isGuest,
    required this.mobile,
    required this.profile,
    required this.token,
    required this.userId,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'decription': decription,
      'email': email,
      'mobile_number': mobile,
      'profile': profile,
      'token': token,
      'userId': userId,
      'isGuest': isGuest,
    };
  }

  UserEntity copyWith(
    String? name,
    String? decription,
    String? email,
    String? mobile,
    String? profile,
    String? token,
    int? userId,
    bool isGuest,
  ) {
    return UserEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      decription: decription ?? this.decription,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      profile: profile ?? this.profile,
      token: token ?? this.token,
      isGuest: isGuest,
    );
  }
}
