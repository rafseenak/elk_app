import 'dart:async';

import 'package:elk/bloc/event/otp_screen_event.dart';
import 'package:elk/bloc/state/otp_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OTPSreenBloc extends Bloc<OTPScreenEvent, OTPScreenState> {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  Timer? _timer;
  OTPSreenBloc({
    required this.phoneNumber,
    required this.verificationId,
    required this.resendToken,
  }) : super(OTPScreenState(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
            resendToken: resendToken,
            duration: 60)) {
    on<AddOtp>((event, emit) => emit(state.copyWith(otp: event.otp)));
    on<ResendTimerStart>((event, emit) => startTimer(emit));
    on<ResendTimerProgress>(
        (event, emit) => emit(state.copyWith(duration: event.timer)));
    on<ResendOtp>((event, emit) => restartTimer(emit));
    on<UpdateVerificationId>((event, emit) =>
        emit(state.copyWith(verificationId: event.verificationId)));
  }

  Future<void> startTimer(Emitter<OTPScreenState> emit) async {
    _timer ??=
        Timer.periodic(const Duration(seconds: 1), (time) => ticker(time));
  }

  Future<void> restartTimer(Emitter<OTPScreenState> emit) async {
    _timer?.cancel(); // Cancel the existing timer if any
    emit(state.copyWith(duration: 60));
    startTimer(emit); // Start a new timer

    // emit(state.copyWith(duration: 60));

    // _timer ??=
    //     Timer.periodic(const Duration(seconds: 1), (time) => ticker(time));
  }

  ticker(Timer time) {
    if (state.duration < 1) {
      _timer!.cancel();
      _timer = null;
    } else {
      add(ResendTimerProgress(state.duration - 1));
    }
  }
}
