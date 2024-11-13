// ignore_for_file: implementation_imports, unused_import, unnecessary_import, depend_on_referenced_packages, library_prefixes

import 'dart:math';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart'
    as c;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as locationService;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MapEntry<int, dynamic> findLeastItem(List<dynamic> list) {
  if (list is List<String>) {
    return list.asMap().entries.reduce((prev, curr) {
      double prevValue = double.parse(prev.value);
      double currValue = double.parse(curr.value);
      return prevValue < currValue ? prev : curr;
    });
  } else {
    return list.asMap().entries.reduce((prev, curr) {
      double prevValue = prev.value;
      double currValue = curr.value;
      return prevValue < currValue ? prev : curr;
    });
  }
}

MapEntry<int, dynamic> findMostItem(List<dynamic> list) {
  if (list is List<String>) {
    return list.asMap().entries.reduce((prev, curr) {
      double prevValue = double.parse(prev.value);
      double currValue = double.parse(curr.value);
      return prevValue > currValue ? prev : curr;
    });
  } else {
    return list.asMap().entries.reduce((prev, curr) {
      double prevValue = prev.value;
      double currValue = curr.value;
      return prevValue > currValue ? prev : curr;
    });
  }
}

String convertToMeterOrKelometer(double? value) {
  if (value != null) {
    final meter = value * 1000;
    if (meter < 1) {
      return '${meter.toStringAsFixed(2)} m';
    }
    return '${value.toStringAsFixed(2)} km';
  } else {
    return '';
  }
}

Future<void> lauchGMapFromCoordinated(double latitude, double longitude) async {
  String mapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';
  try {
    if (await canLaunchUrl(Uri.parse(mapsUrl))) {
      launchUrl(Uri.parse(mapsUrl));
    } else {
      debugPrint('Could not launch Google Maps');
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> launchPhone(String phone) async {
  final url = 'tel:$phone';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Coudent lauch url $url';
  }
}

Future<void> launchMail(String mail) async {
  final url = 'mailto:$mail';
  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<String?> selectImage() async {
  final imagePicker = ImagePicker();
  final response = await imagePicker.pickImage(source: ImageSource.gallery);
  if (response == null) {
    return null;
  } else {
    return response.path;
  }
}

Future<String?> cropImage(String imagePath) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imagePath,
    compressQuality: 100,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: '',
        toolbarColor: const Color.fromARGB(255, 0, 0, 0),
        toolbarWidgetColor: const Color.fromARGB(255, 255, 255, 255),
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        hideBottomControls: true,
        showCropGrid: true,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
      ),
      IOSUiSettings(
        title: 'Cropper',
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
      ),
    ],
  );
  return croppedFile?.path;
}

Future<List<String>> pickMultiImage() async {
  final imagePicker = ImagePicker();
  final response = await imagePicker.pickMultiImage();
  List<String> paths = [];
  for (var element in response) {
    final croppedPath = await cropImage(element.path);
    if (croppedPath != null) {
      paths.add(croppedPath);
    }
  }
  return paths;
}

Future<String?> takeCamer() async {
  final imagePicker = ImagePicker();
  final response = await imagePicker.pickImage(source: ImageSource.camera);
  if (response != null) {
    return await cropImage(response.path);
  }
  return null;
}
// Future<List<String>> pickMultiImage() async {
//   final imagePicker = ImagePicker();
//   final response = await imagePicker.pickMultiImage();
//   List<String> paths = [];
//   for (var element in response) {
//     paths.add(element.path);
//   }
//   return paths;
// }

// Future<String?> takeCamer() async {
//   final imagePicker = ImagePicker();
//   final response = await imagePicker.pickImage(source: ImageSource.camera);
//   if (response == null) {
//     return null;
//   } else {
//     return response.path;
//   }
// }

Future<String?> selectVideo() async {
  final imagePicker = ImagePicker();
  final response = await imagePicker.pickImage(source: ImageSource.gallery);
  if (response == null) {
    return null;
  } else {
    return response.path;
  }
}

Future<PermissionStatus> notificationStatus() async {
  var status = await Permission.notification.status;
  return status;
}

Future<PermissionStatus> notificationRequest() async {
  var status = await Permission.notification.request();
  return status;
}

UserType getUserType(context) {
  AppAuthProvider authProvider =
      Provider.of<AppAuthProvider>(context, listen: false);
  return authProvider.authUser!.userType;
}

AppLocalizations localisation(BuildContext context) {
  return AppLocalizations.of(context)!;
}

String localisationSwitch(BuildContext context, String title) {
  AppLocalizations localizations = localisation(context);
  String item = title;
  switch (title) {
    case 'Car':
      item = localizations.car;
      break;
    case 'Property':
      item = localizations.property;
      break;
    case 'Electronics':
      item = localizations.electronics;
      break;
    case 'Furniture':
      item = localizations.furniture;
      break;
    case 'Bike':
      item = localizations.bike;
      break;
    case 'Cloth':
      item = localizations.cloth;
      break;
    case 'Helicopter':
      item = localizations.helicopter;
      break;
    case 'Cleaning':
      item = localizations.cleaning;
      break;
    case 'Repairing':
      item = localizations.repairing;
      break;
    case 'Painting':
      item = localizations.paiting;
      break;
    case 'Electrician':
      item = localizations.electrician;
      break;
    case 'Carpentry':
      item = localizations.carpentry;
      break;
    case 'Laundry':
      item = localizations.laundry;
      break;
    case 'Tools':
      item = localizations.tools;
      break;
    case 'Salon':
      item = localizations.saloon;
      break;
    case 'Plumbing':
      item = localizations.plumbing;
      break;
    case 'Other':
      item = localizations.other;
      break;
    default:
      item = title;
  }

  return item;
}

double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
  final width = MediaQuery.of(context).size.width;
  double val = (width / 1400) * maxTextScaleFactor;
  return max(0.9, min(val, maxTextScaleFactor));
}
