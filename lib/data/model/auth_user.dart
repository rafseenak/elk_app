import 'package:elk/data/enum/user_type.dart';

class AuthUser {
  final String? name;
  final String? mobile;
  final String? email;
  final String? profile;
  final UserType userType;
  final String token;
  final int? userId;
  AuthUser({
    this.name,
    this.mobile,
    this.email,
    this.profile,
    required this.userType,
    required this.token,
    this.userId,
  });

  AuthUser copyWith({
    String? name,
    String? mobile,
    String? email,
    String? profile,
    UserType? userType,
    String? token,
    int? userId,
  }) {
    return AuthUser(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      userType: userType ?? this.userType,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }
}
