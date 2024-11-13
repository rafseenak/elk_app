import 'package:elk/bloc/event/spash_Screen_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, int> {
  SplashScreenBloc() : super(0) {
    on<SplashScreenFade>((event, emit) => {});
  }
}
