// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DefualtResponse {
  final bool success;
  final String message;
  Map<String, dynamic>? data;
  DefualtResponse({required this.success, required this.message, this.data});

  factory DefualtResponse.fromJson(Map<String, dynamic> json) {
    return DefualtResponse(
        success: json['success'], message: json['message'], data: json['data']);
  }
}
