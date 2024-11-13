// ignore_for_file: unused_import

import 'package:elk/network/entity/user_contact.dart';
import 'package:elk/network/entity/ads_category.dart';

abstract class AdPostState {}

class AdPostInitialState extends AdPostState {}

class AdPostLoadState extends AdPostState {
  final List<AdCategory> rentCategoryList;
  final List<AdCategory> serviceList;
  AdPostLoadState(this.rentCategoryList, this.serviceList);
}

class AdPostUpdateUserProfileState extends AdPostState {}
