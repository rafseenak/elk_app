import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/data/model/user_model.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final AppAuthProvider appAuthProvider;
  final UserRepository userRepository;
  ProfileProvider(this.appAuthProvider, {required this.userRepository}) {
    initState();
  }
  bool isLoading = true;
  User? user;

  Future<void> initState() async {
    isLoading = true;
    final res = await userRepository.getUser(appAuthProvider.authUser?.userId);
    if (res.success) {
      user = res.data;
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<DataSet<String>> authUserDetails(String path) async {
  //   final res = await userRepository.getUser(appAuthProvider.authUser?.userId);
  //   if (res.success) {
  //     user = user!.copyWith(profile: res.data);
  //     appAuthProvider.updateProfilePic(user!.profile!);
  //     notifyListeners();
  //     return res;
  //   } else {
  //     return res;
  //   }
  // }

  Future<DataSet<String>> uploadProfilePic(String path) async {
    final res = await userRepository.updateProfilePic(
        path, appAuthProvider.authUser?.userId);
    if (res.success) {
      user = user!.copyWith(profile: res.data);
      appAuthProvider.updateProfilePic(user!.profile!);
      if (user!.profile != null) {
        CachedNetworkImage.evictFromCache(user!.profile!);
      }
      notifyListeners();
    }
    return res;
  }

  Future<DataSet<String>> updateProfile(String name, String description) async {
    final res = await userRepository.updateProfile(
        name, description, appAuthProvider.authUser?.userId);
    if (res.success) {
      user = user!.copyWith(name: name, decription: description);
      appAuthProvider.updateName(user!.name!);
      notifyListeners();
    }
    return res;
  }

  Future<DataSet<String>> updateMobileOrEmail(String type, String value,
      {String? uid}) async {
    final res = await userRepository.updateEmailOrMobile(
        type, appAuthProvider.authUser?.userId, value,
        uid: uid);
    if (res.success) {
      if (type == 'mobile') {
        user = user!.copyWith(mobile: value);
        appAuthProvider.updateEmailOrMobile('mobile', user!.mobile!);
      } else {
        user = user!.copyWith(email: value);
        appAuthProvider.updateEmailOrMobile('email', user!.email!);
      }
      notifyListeners();
    }
    return res;
  }
}
