import 'package:equatable/equatable.dart';

abstract class OTPScreenEvent extends Equatable {}

class SubmitOtp extends OTPScreenEvent {
  @override
  List<Object?> get props => [];
}

class ResendTimerStart extends OTPScreenEvent {
  final int time;
  ResendTimerStart(this.time);

  @override
  List<Object?> get props => [time];
}

class ResendTimerProgress extends OTPScreenEvent {
  final int timer;
  ResendTimerProgress(this.timer);

  @override
  List<Object?> get props => [timer];
}

class ResendOtp extends OTPScreenEvent {
  final int timer;
  ResendOtp({required this.timer});

  @override
  List<Object?> get props => [];
}

class UpdateVerificationId extends OTPScreenEvent {
  final String verificationId;
  UpdateVerificationId({required this.verificationId});
  @override
  List<Object?> get props => [verificationId];
}

class AddOtp extends OTPScreenEvent {
  final String otp;
  AddOtp(this.otp);

  @override
  List<Object?> get props => [otp];
}
