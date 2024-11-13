// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'ads_category.g.dart';

@JsonSerializable()
class AdCategory {
  final String title;
  final String category;
  final String image;

  AdCategory(
      {required this.title, required this.category, required this.image});

  factory AdCategory.fromJson(Map<String, dynamic> json) =>
      _$AdCategoryFromJson(json);
}
