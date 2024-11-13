// ignore_for_file: unused_import

import 'dart:convert';

import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/model/location.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/enum/location_type.dart';

class AppPrefrences {
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _mobileKey = 'mobile';
  static const String _profileKey = 'profile';
  static const String _userTypeKey = 'userType';
  static const String _authTokenKey = 'authToken';
  static const String _userId = 'userId';
  static const String _locationKey = 'location';
  static const String _notificationKey = 'notification';
  static const String _languageKey = 'language';

  static Future<void> setUser(AuthUser authUser, UserType userType) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_nameKey, authUser.name ?? '');
    prefs.setString(_emailKey, authUser.email ?? '');
    prefs.setString(_mobileKey, authUser.mobile ?? '');
    prefs.setString(_profileKey, authUser.profile ?? '');
    prefs.setString(_userTypeKey, userType.toString());
    prefs.setString(_authTokenKey, authUser.token);
    prefs.setInt(_userId, authUser.userId ?? 0);
  }

  static Future<AuthUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_nameKey);
    String? email = prefs.getString(_emailKey);
    String? mobile = prefs.getString(_mobileKey);
    String? profile = prefs.getString(_profileKey);
    String? userType = prefs.getString(_userTypeKey);
    String? authToken = prefs.getString(_authTokenKey);
    int? userId = prefs.getInt(_userId);
    if (userType != null && authToken != null) {
      UserType userTypeEnum =
          UserType.values.firstWhere((e) => e.toString() == userType);
      return AuthUser(
        name: name,
        email: email,
        mobile: mobile,
        profile: profile,
        userType: userTypeEnum,
        token: authToken,
        userId: userId,
      );
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setLocation(Location location) async {
    final prefs = await SharedPreferences.getInstance();
    final _ = jsonEncode({
      'locationType': location.locationType.toString(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'locality': location.locality,
      'place': location.place,
      'district': location.district,
      'state': location.state,
      'country': location.country,
    });
    prefs.setString(_locationKey, _);
  }

  static Future<String?> isLocationAdded() async {
    final prefs = await SharedPreferences.getInstance();
    final abc = prefs.getString(_locationKey);
    return abc;
  }

  static Future<void> setNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_notificationKey, value);
  }

  static Future<bool?> getNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationKey);
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageKey, language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
}
