class OTPScreenState {
  final int duration;
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final String otp;

  OTPScreenState(
      {required this.phoneNumber,
      required this.verificationId,
      required this.resendToken,
      required this.duration,
      this.otp = ''});

  OTPScreenState copyWith(
      {int? duration,
      String? phoneNumber,
      String? verificationId,
      int? resendToken,
      String? otp}) {
    return OTPScreenState(
        phoneNumber: phoneNumber ?? this.phoneNumber,
        verificationId: verificationId ?? this.verificationId,
        resendToken: resendToken ?? this.resendToken,
        duration: duration ?? this.duration,
        otp: otp ?? this.otp);
  }
}
