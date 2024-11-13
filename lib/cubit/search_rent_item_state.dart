import 'package:elk/network/entity/search_rent_item.dart';

abstract class SearchRentItemState {}

class SearchRentItemInitialState extends SearchRentItemState {}

class SearchRentItemLoadState extends SearchRentItemState {
  final List<SearchRentItem> currentData;

  SearchRentItemLoadState({required this.currentData});
}
