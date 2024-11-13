import 'package:elk/utils/app_preferences.dart';
import 'package:flutter/material.dart';

class AppLanguageNotifier extends ChangeNotifier {
  Locale _defualtLanguage = const Locale('en');
  AppLanguageNotifier() {
    getLanguage();
  }

  Future<void> getLanguage() async {
    await AppPrefrences.getLanguage().then((value) {
      _defualtLanguage = Locale(value);
      notifyListeners();
    });
  }

  Locale get currentLanguage => _defualtLanguage;

  changeCurrentLanguage(Locale language) {
    AppPrefrences.setLanguage(language.languageCode);
    _defualtLanguage = language;
    notifyListeners();
  }
}
