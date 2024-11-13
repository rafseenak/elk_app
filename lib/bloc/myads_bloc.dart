import 'package:elk/bloc/event/myads_event.dart';
import 'package:elk/bloc/state/myads_state.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAdsBloc extends Bloc<MyAdsEvent, MyAdsState> {
  final RentAdsRepository rentAdsRepository;
  MyAdsBloc(this.rentAdsRepository) : super(MyAdsState(true, false, [])) {
    on<MyAdsInitialEvent>((event, emit) => emit(MyAdsState(true, false, [])));
    on<MyAdsLoadEvent>((event, emit) => _loadAds(emit));
  }

  Future<void> _loadAds(Emitter<MyAdsState> emit) async {
    final res = await rentAdsRepository.myAds();
    if (res.success) {
      emit(MyAdsState(false, false, res.data!));
    } else {
      emit(MyAdsState(false, true, res.data!));
    }
  }
}
