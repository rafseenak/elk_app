// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'search_rent_item.g.dart';

@JsonSerializable()
class SearchRentItem {
  final String keyword;
  final String category;

  SearchRentItem({required this.keyword, required this.category});
  factory SearchRentItem.fromJson(Map<String, dynamic> json) =>
      _$SearchRentItemFromJson(json);
}
