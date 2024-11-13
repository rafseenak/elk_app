import 'dart:async';

import 'package:elk/cubit/loaction_search_state.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/network/entity/place_search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationSearchCubit extends Cubit<LocationSearchState> {
  final PlaceRepository placeRepository;

  LocationSearchCubit({required this.placeRepository})
      : super(InitialLocationSearchState());
  final bool hasMoreData = false;
  final List<PlaceSearch> _list = [];
  String _searchQuery = '';
  Timer? _debounce;

  searchLocations(String query, bool limited, int offset,
      {double? latitude, double? longitude}) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      List<PlaceSearch> newList = await placeRepository.searchPlace(
          query, limited, _searchQuery == query ? offset : 0,
          latitude: latitude, longitude: longitude);

      if (_searchQuery == query) {
        _list.addAll(newList);

        if (newList.length < 15) {
          emit(LoadPlacesDataState(false, List.from(_list)));
        } else {
          emit(LoadPlacesDataState(true, List.from(_list)));
        }
      } else {
        _list.clear();
        _list.addAll(newList);
        if (newList.length < 15) {
          emit(LoadPlacesDataState(false, List.from(_list)));
        } else {
          emit(LoadPlacesDataState(true, List.from(_list)));
        }
      }
      _searchQuery = query;
    });
  }
}
