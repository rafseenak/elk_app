// ignore_for_file: unused_import

import 'package:either_dart/either.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/data/model/otp_failed.dart';
import 'package:elk/data/model/otp_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

abstract class AuthImplimentaion {
  Future<void> googleSignin();
  Future<void> phoneSignIn(
      BuildContext context, LoginScreenBloc bloc, String phoneNumber);
  Future<void> verifyPhoneNumber(String verificationId, String otp);
}
