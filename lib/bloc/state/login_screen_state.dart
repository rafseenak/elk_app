import 'package:elk/data/model/auth_status.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreenState {
  AuthStatus authStatus = AuthStatus();
  final User? user;
  final bool otpIsSending;
  LoginScreenState({this.otpIsSending = false, this.user});

  LoginScreenState copyWith({User? user, bool? otpSending}) {
    return LoginScreenState(
        otpIsSending: otpSending ?? otpIsSending, user: user ?? this.user);
  }
}
