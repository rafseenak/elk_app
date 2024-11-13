import 'package:elk/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: Constants.primaryColor,
  primarySwatch: Colors.amber,
  canvasColor: Colors.white,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.montserrat(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark)),
  tabBarTheme: TabBarTheme(
      indicatorColor: Constants.primaryColor,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: GoogleFonts.poppins(),
      unselectedLabelStyle: GoogleFonts.poppins()),
  textTheme: TextTheme(
      headlineSmall: GoogleFonts.montserrat(
          fontSize: 25, fontWeight: FontWeight.w300, color: Colors.black),
      headlineMedium:
          GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w300),
      headlineLarge: GoogleFonts.montserrat(
          fontSize: 31, fontWeight: FontWeight.w300, color: Colors.black),
      bodySmall: GoogleFonts.montserrat(
          fontSize: 11, fontWeight: FontWeight.w300, color: Colors.black),
      bodyMedium: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      bodyLarge: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
  buttonTheme: ButtonThemeData(
      disabledColor: Colors.grey.shade500, buttonColor: Colors.amber),
  filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade500;
            }
            return Colors.white;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300;
            }
            return Constants.primaryColor;
          }),
          overlayColor: const MaterialStatePropertyAll(Colors.amber),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10)),
          textStyle: MaterialStatePropertyAll(GoogleFonts.montserrat(
              fontSize: 15, fontWeight: FontWeight.w600)))),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return const BorderSide(width: 0, color: Colors.transparent);
            }
            return const BorderSide(color: Constants.primaryColor);
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return Colors.black;
          }),
          overlayColor: const MaterialStatePropertyAll(Constants.primaryColor),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10)),
          textStyle: MaterialStatePropertyAll(GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          )))),
  textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          padding: const MaterialStatePropertyAll(
              EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10)),
          textStyle: MaterialStatePropertyAll(GoogleFonts.montserrat(
              fontSize: 15, fontWeight: FontWeight.w600)))),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Constants.primaryColor,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Constants.primaryColor),
    trackColor: MaterialStateProperty.all(Colors.grey.shade200),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Constants.primaryColor,
    linearTrackColor: Colors.amber,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Constants.primaryColor,
    inactiveTrackColor: Colors.grey,
    thumbColor: Constants.primaryColor,
    overlayColor: Constants.primaryColor.withAlpha(32),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(Constants.primaryColor),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all(Constants.primaryColor),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Constants.primaryColor,
  ),
);
