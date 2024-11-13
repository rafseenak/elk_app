abstract class LoginScreeEvent {}

class GoogleLogin extends LoginScreeEvent {}

class PhoneLogin extends LoginScreeEvent {
  final String phoneNumber;
  PhoneLogin({required this.phoneNumber});
}

class OTPsending extends LoginScreeEvent{}

class OTPsended extends LoginScreeEvent{}


class OTPSendingFailed extends LoginScreeEvent{}
