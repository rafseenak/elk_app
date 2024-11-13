import 'package:elk/network/entity/ad_response.dart';

abstract class ServiceState {}

class ServiceStateInitial extends ServiceState {}

class ServiceLoadState extends ServiceState {
  final bool hasMore;
  final List<AdResponse> currentData;

  ServiceLoadState(this.hasMore, this.currentData);
}
