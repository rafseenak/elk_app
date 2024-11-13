// ignore_for_file: unused_import, unused_field

import 'package:elk/cubit/rent_products_state.dart';
import 'package:elk/cubit/search_rent_item_state.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/search_rent_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class SearchRentItemCubit extends Cubit<SearchRentItemState> {
  final RentAdsRepository rentAdsRepository;
  SearchRentItemCubit(this.rentAdsRepository)
      : super(SearchRentItemInitialState());

  final List<SearchRentItem> _list = [];
  String _oldKeyword = '';

  Future<void> searchCategory(String keyword, String adType) async {
    final data = await rentAdsRepository.searchRentItem(keyword, adType);
    _list.clear();
    data.match((l) {}, (r) {
      _oldKeyword = keyword;
      _list.addAll(r);
      emit(SearchRentItemLoadState(currentData: _list));
    });
  }
}
