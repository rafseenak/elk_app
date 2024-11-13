import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/model/user_model.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/network/entity/ad_user.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/defualt_response.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  UserRepository();
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<DataSet<AuthUser>> guestSignIn() async {
    final res = await _apiClient.createGuest();
    if (res.success) {
      return DataSet.success(AuthUser(
        userType: UserType.guest,
        token: res.data!.token!,
        userId: res.data!.userId!,
      ));
    } else {
      return DataSet.error(res.message);
    }
  }

  Future<DataSet<Map>> sendOtp(String mobile) async {
    final res = await _apiClient.sendOtp(mobile);
    return res;
  }

  Future<DataSet<AuthUser>> verifyOtp(String verificationId, int otp) async {
    final res = await _apiClient.verifyOto(verificationId, otp);
    if (res.success) {
      return DataSet.success(AuthUser(
        name: res.data!['name'],
        email: res.data!['email'],
        mobile: res.data!['mobile_number'],
        profile: res.data!['profile'],
        userType: UserType.user,
        token: res.data!['token'],
        userId: res.data!['user_id'],
      ));
    } else {
      return DataSet.error(res.message);
    }
  }

  Future<AuthUser?> signin(
      String type, String name, String authBase, String uuid) async {
    DefualtResponse defualtResponse = await _apiClient.createUser(
        type: type, name: name, authBase: authBase, uuid: uuid);
    if (defualtResponse.success) {
      return AuthUser(
          name: defualtResponse.data!['name'],
          email: defualtResponse.data!['email'],
          mobile: defualtResponse.data!['mobile_number'],
          profile: defualtResponse.data!['profile'],
          userType: UserType.user,
          token: defualtResponse.data!['token'],
          userId: defualtResponse.data!['user_id']);
    } else {
      return null;
    }
  }

  Future<DataSet<String>> updateEmailOrMobile(
      String type, int? userId, String value,
      {String? uid}) async {
    final res =
        await _apiClient.updateEmailOrMobile(type, userId, value, uid: uid);
    return res;
  }

  Future<DataSet<String>> updateProfile(
      String name, String description, int? userId) async {
    final res = await _apiClient.updateProfile(name, description, userId);
    return res;
  }

  Future<DataSet<User>> getUser(int? userId) async {
    final res = await _apiClient.getUser(userId);
    if (res.success) {
      return DataSet.success(User.fromUserEntity(res.data!));
    } else {
      return DataSet.error(res.message);
    }
  }

  Future<DataSet<String>> updateProfilePic(String path, int? userId) async {
    final res = await _apiClient.updateProfilePic(path, userId);
    return res;
  }

  Future<DataSet<AdUser>> userWithAds(int? userId) async {
    final res = await _apiClient.userWithAds(userId);
    return res;
  }

  Future<DataSet<List<AdResponse>>> userWishlists() async {
    final res = await _apiClient.userWishlists();
    return res;
  }

  Future<DataSet<String>> removeWishlist(int adId, int a) async {
    final res = await _apiClient.removeWishlist(adId);
    return res;
  }

  Future<DataSet<String>> updateNotificationToken(String token) async {
    final res = await _apiClient.updateNotificationToken(token);
    return res;
  }
}
