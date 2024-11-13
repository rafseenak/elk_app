import 'package:elk/network/entity/ad_response.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadState extends HomeState {
  final bool hasMore;
  final List<AdResponse> currentData;

  HomeLoadState({required this.hasMore, required this.currentData});
}
