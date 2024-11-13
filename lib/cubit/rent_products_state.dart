import 'package:elk/network/entity/ad_response.dart';

abstract class RentProductsState {}

class RentProductsInitialState extends RentProductsState {}

class RentProductsLoadState extends RentProductsState {
  final int total;
  final bool hasMore;

  final List<AdResponse> list;
  RentProductsLoadState(
      {
      required this.total,
      required this.hasMore,
      required this.list});
}
