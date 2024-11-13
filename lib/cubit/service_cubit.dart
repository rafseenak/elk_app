import 'package:elk/cubit/service_state.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final RentAdsRepository rentAdsRepository;
  ServiceCubit(this.rentAdsRepository) : super(ServiceStateInitial());
  final int _page = 1;
  final List<AdResponse> _list = [];

  Future<void> bestServiceProviders(Location location) async {
    final typedLocation = location.locationType == LocationType.locality
        ? location.locality
        : location.locationType == LocationType.place
            ? location.place
            : location.locationType == LocationType.district
                ? location.district
                : location.locationType == LocationType.state
                    ? location.state
                    : location.country;
    final res = await rentAdsRepository.bestServiceProviders(
        location.locationType,
        typedLocation!,
        location.latitude,
        location.longitude,
        _page);

    res.match((l) {}, (r) {
      _list.addAll(r.adResponses);
      emit(ServiceLoadState(true, List.from(_list)));
    });
  }
}
