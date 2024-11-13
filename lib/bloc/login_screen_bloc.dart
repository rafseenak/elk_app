import 'package:elk/bloc/event/login_screen_event.dart';
import 'package:elk/bloc/state/login_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreenBloc extends Bloc<LoginScreeEvent, LoginScreenState> {
  LoginScreenBloc() : super(LoginScreenState()) {
    on<OTPsending>(
        (event, emit) => emit(LoginScreenState().copyWith(otpSending: true)));
    on<OTPsended>(
        (event, emit) => emit(LoginScreenState().copyWith(otpSending: false)));
    on<OTPSendingFailed>(
        (event, emit) => emit(LoginScreenState().copyWith(otpSending: false)));
    on<PhoneLogin>((event, emit) => {});
  }
}
