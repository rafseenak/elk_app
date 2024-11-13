// ignore_for_file: unused_import

import 'package:elk/cubit/home_state.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final RentAdsRepository rentAdsRepository;
  HomeCubit(this.rentAdsRepository) : super(HomeInitialState());
  int _page = 1;
  final List<AdResponse> _list = [];

  Future<void> fetchRecommentedPosts() async {
    final res = await rentAdsRepository.recometedPosts(_page);
    res.match((l) {}, (r) {
      if (r.adResponses.isNotEmpty) {
        _list.addAll(r.adResponses);
        emit(HomeLoadState(
            hasMore: _list.length < r.total ? true : false,
            currentData: List.from(_list)));
        _page = _page + 1;
      } else {
        emit(HomeLoadState(hasMore: false, currentData: List.from([])));
      }
    });
  }
}
