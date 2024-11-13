import 'package:elk/cubit/rent_products_state.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RentProductsCubit extends Cubit<RentProductsState> {
  final RentAdsRepository rentAdsRepository;
  RentProductsCubit(this.rentAdsRepository) : super(RentProductsInitialState());

  final List<AdResponse> _data = [];
  int _currentPage = 1;

  Future<void> loadProducts(Location location, String? category,
      String? keyword, String adType) async {
    debugPrint('currentPage:$_currentPage');

    final locationByName = location.locationType == LocationType.locality
        ? location.locality
        : location.locationType == LocationType.place
            ? location.place
            : location.locationType == LocationType.district
                ? location.district
                : location.locationType == LocationType.state
                    ? location.state
                    : location.country;
    debugPrint('locationByName:$locationByName');
    final adRes = await rentAdsRepository.rentCategoryPosts(
        category,
        keyword,
        adType,
        _currentPage,
        location.latitude,
        location.longitude,
        location.locationType,
        locationByName!);
    debugPrint('adRes:$adRes');

    adRes.match((l) {}, (r) {
      _data.addAll(r.adResponses);
      debugPrint('Total : ${r.total}');
      debugPrint('length of data : ${_data.length}');
      _currentPage = _data.length ~/ 15;
      debugPrint('_currentPage:$_currentPage');
      if ((_currentPage * 15) < r.total) {
        emit(RentProductsLoadState(
            total: r.total,
            hasMore: r.adResponses.length > 14,
            list: List.from(_data)));
      } else {
        emit(RentProductsLoadState(
            total: r.total, hasMore: false, list: List.from(_data)));
      }
      _currentPage = _currentPage + 1;
      debugPrint('currentPage : ${_currentPage - 1}');
    });
  }
}
