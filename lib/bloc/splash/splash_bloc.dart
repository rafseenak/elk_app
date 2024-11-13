import 'package:bloc/bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStart>((event, emit) async {
      await Future.delayed(const Duration(seconds: 5));
      emit(SplashFinished());
    });
  }
}
