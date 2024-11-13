// ignore_for_file: unused_import, unnecessary_brace_in_string_interps
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:either_dart/either.dart';
import 'package:elk/bloc/event/login_screen_event.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/model/otp_failed.dart';
import 'package:elk/data/model/otp_success.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/provider/auth_implimentations.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AppAuthProvider extends ChangeNotifier implements AuthImplimentaion {
  final UserRepository userRepository;
  AppAuthProvider(this.userRepository);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<AuthUser?> _streamController =
      StreamController<AuthUser?>.broadcast();
  Stream<AuthUser?> get authUserStram => _streamController.stream;
  AuthUser? authUser;
  final StreamController<bool> _authStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get authStram => _authStreamController.stream;

  Future<DataSet<bool>> guestSignIn() async {
    final res = await userRepository.guestSignIn();
    if (res.success) {
      AppPrefrences.setUser(res.data!, UserType.guest);
      authUser = res.data;
      _streamController.add(authUser);
      _authStreamController.add(authUser != null ? true : false);
      notifyListeners();
      return DataSet.success(true);
    } else {
      return DataSet.error(res.message!);
    }
  }

  Future<DataSet<Map>> sendOtp(mobile) async {
    return userRepository.sendOtp(mobile);
  }

  Future<DataSet> verifyOtp(String verificationId, int otp) async {
    final res = await userRepository.verifyOtp(verificationId, otp);
    if (res.success) {
      AuthUser newAuthUser = res.data!;
      AppPrefrences.setUser(newAuthUser, UserType.user);
      authUser = newAuthUser;
      _streamController.add(authUser);
      _authStreamController.add(authUser != null ? true : false);
      notifyListeners();
      return DataSet.success(null);
    } else {
      return DataSet.error(res.message);
    }
  }

  @override
  Future<DataSet<bool>> googleSignin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential data = await _auth.signInWithCredential(credential);
      User? user = data.user;
      AuthUser? newaAuthUser = await userRepository.signin(
          'email', user!.displayName!, user.email!, user.uid);
      if (newaAuthUser != null) {
        AppPrefrences.setUser(newaAuthUser, UserType.user);
        authUser = newaAuthUser;
        _streamController.add(authUser);
        _authStreamController.add(authUser != null ? true : false);
        notifyListeners();
        return DataSet.success(true);
      }
      return DataSet.error('Something went wrong');
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        debugPrint('Google sign network error');
        return DataSet.error('Connection error');
      } else {
        debugPrint('Error signing in with Google1: $e');
        return DataSet.error(e.toString());
      }
    } catch (e) {
      debugPrint('Error signing in with Google2: $e');
      return DataSet.error(e.toString());
    }
  }

  @override
  Future<void> phoneSignIn(
      BuildContext context, LoginScreenBloc bloc, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          Fluttertoast.showToast(msg: authException.code);
          bloc.add(OTPSendingFailed());
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
              'verification id : $verificationId, resend Token : $resendToken');
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  @override
  Future<bool> verifyPhoneNumber(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    try {
      UserCredential data = await _auth.signInWithCredential(credential);
      User? user = data.user;
      AuthUser? newauthUser = await userRepository.signin(
        'mobile',
        user!.displayName == null ? 'user' : user.displayName!,
        user.phoneNumber!,
        user.uid,
      );
      if (newauthUser != null) {
        AppPrefrences.setUser(newauthUser, UserType.user);
        authUser = newauthUser;
        _streamController.add(authUser);
        _authStreamController.add(true);
        notifyListeners();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Fluttertoast.showToast(msg: e.code);
      } else if (e.code == 'network-request-failed') {
        Fluttertoast.showToast(msg: 'connection error');
      }
      debugPrint(e.code);
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> isSignedIn() async {
    AuthUser? prefAuthUser = await AppPrefrences.getUser();
    authUser = prefAuthUser;
    _streamController.add(authUser);
    _authStreamController.add(authUser != null ? true : false);
    notifyListeners();
    if (authUser != null) {
      return true;
    }
    return false;
  }

  Future<void> updateName(String name) async {
    final newUser = authUser!.copyWith(name: name);
    authUser = newUser;
    await AppPrefrences.setUser(authUser!, authUser!.userType);
    _streamController.add(authUser);
    notifyListeners();
  }

  Future<void> updateEmailOrMobile(String type, String value) async {
    if (type == 'mobile') {
      final newUser = authUser!.copyWith(mobile: value);
      authUser = newUser;
      await AppPrefrences.setUser(authUser!, authUser!.userType);
      _streamController.add(authUser);
      notifyListeners();
    } else {
      final newUser = authUser!.copyWith(email: value);
      authUser = newUser;
      await AppPrefrences.setUser(authUser!, authUser!.userType);
      _streamController.add(authUser);
      notifyListeners();
    }
  }

  Future<void> updateProfilePic(String profile) async {
    final newUser = authUser!.copyWith(profile: profile);
    authUser = newUser;
    if (authUser!.profile != null) {
      CachedNetworkImage.evictFromCache(authUser!.profile!);
    }
    await AppPrefrences.setUser(authUser!, authUser!.userType);
    _streamController.add(authUser);
    notifyListeners();
  }
}
