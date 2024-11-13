// ignore_for_file: unused_import

import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository locationRepository;
  LocationCubit({required this.locationRepository})
      : super(LocationInitialState());

  Future<void> changeLocation(Location location) async {
    await Future.delayed(const Duration(seconds: 2));
    await locationRepository.setLocationAddes(location);
    emit(LocationLoadState(location: location));
  }
}
