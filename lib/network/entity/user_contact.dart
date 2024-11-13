// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'user_contact.g.dart';

@JsonSerializable()
class UserContact {
  final String? name;
  @JsonKey(name: 'mobile_number')
  final String? mobile;
  final String? email;
  UserContact({required this.name, required this.mobile, required this.email});

  factory UserContact.fromJson(Map<String, dynamic> json) =>
      _$UserContactFromJson(json);
}
