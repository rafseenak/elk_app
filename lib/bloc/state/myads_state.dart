import 'package:elk/network/entity/ad_response.dart';

class MyAdsState {
  final bool isLoading;
  final bool error;
  final List<AdResponse> listAdresponses;

  MyAdsState(this.isLoading, this.error, this.listAdresponses);
}
