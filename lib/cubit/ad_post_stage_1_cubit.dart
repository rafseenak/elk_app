import 'package:elk/cubit/ad_post_stage_1_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostSatge1Cubit extends Cubit<AdPostSatge1State> {
  AdPostSatge1Cubit()
      : super(AdPostSatge1State(title: '', description: '', priceDetails: {}));
}
