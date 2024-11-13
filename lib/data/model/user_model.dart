import 'package:elk/network/entity/user_entity.dart';

class User {
  final String? name;
  final String? decription;
  final String? email;

  final String? mobile;
  final String? profile;
  User(
      {required this.name,
      required this.decription,
      required this.email,
      required this.mobile,
      required this.profile});

  factory User.fromUserEntity(UserEntity entity) => User(
      name: entity.name,
      decription: entity.decription,
      email: entity.email,
      mobile: entity.mobile,
      profile: entity.profile);

  User copyWith({String? name, String? decription, String? email, String? mobile,
      String? profile}) {
    return User(
        name: name ?? this.name,
        decription: decription ?? this.decription,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        profile: profile ?? this.profile);
  }
}
