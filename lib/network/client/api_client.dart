// ignore_for_file: unused_catch_clause

import 'package:dio/dio.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/exception/dio_network_exception.dart';
import 'package:elk/network/entity/ad_user.dart';
import 'package:elk/network/entity/place_entity.dart';
import 'package:elk/exception/network_exception.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/network/entity/ads_category.dart';
import 'package:elk/network/entity/defualt_response.dart';
import 'package:elk/network/entity/place.dart';
import 'package:elk/network/entity/search_rent_item.dart';
import 'package:elk/network/entity/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

typedef NetworkHandle<T> = Future<Either<String, T>>;

class ApiClient {
  late final Dio _dio;
  CancelToken _placeSearchToken = CancelToken();
  ApiClient({required String baseUrl, required String apiKey}) {
    _dio = Dio()
      ..options.baseUrl = baseUrl
      ..options.headers = {'Authorization': 'Bearer $apiKey'}
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  updateApikey(String apiKey) {
    _dio.options.headers = {'Authorization': 'Bearer $apiKey'};
  }

  Future<DataSet<UserEntity>> createGuest() async {
    try {
      final response = await _dio.get(
        'create_guest',
      );
      if (response.statusCode == 200) {
        return DataSet.success(UserEntity.fromJson(response.data));
      }
      throw Exception('Unknown error');
    } on DioException catch (e) {
      return DataSet.error(e.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DefualtResponse> createUser({
    required String type,
    required String name,
    required String authBase,
    required String uuid,
  }) async {
    try {
      final response = await _dio.post('create_user',
          data: type == 'mobile'
              ? {'name': name, 'mobile': authBase, 'uuid': uuid}
              : {'name': name, 'email': authBase, 'uuid': uuid});
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw NetworkException(
            statusCode: response.statusCode!, message: response.statusMessage!);
      } else if (response.statusCode != null) {
        return DefualtResponse.fromJson(response.data);
      } else {
        throw Exception('Unknown error');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<DataSet<String>> updateEmailOrMobile(
      String type, int? userId, String value,
      {String? uid}) async {
    Map data = {};
    if (type == 'mobile') {
      data = {'mobile': value, 'user_id': userId};
    } else {
      data = {'email': value, 'uid': uid, 'user_id': userId};
    }

    try {
      final res = await _dio.post('update_email_or_mobile', data: data);
      if (res.data['success']) {
        return DataSet.success(res.data['message']);
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> updateProfile(
      String name, String description, int? userId) async {
    try {
      final res = await _dio.post('update_profile',
          data: {'name': name, 'description': description, 'user_id': userId});
      if (res.statusCode == 200 && res.data['success']) {
        return DataSet.success(res.data['message']);
      } else if (res.statusCode! > 200 && res.data != null) {
        return DataSet.error(res.data['message']);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(e.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<UserEntity>> getUser(int? userId) async {
    try {
      final response =
          await _dio.post('get_user', queryParameters: {'id': userId});
      UserEntity entity = UserEntity.fromJson(response.data);
      return DataSet.success(entity);
    } on DioException catch (e) {
      return DataSet.error(e.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> updateProfilePic(String path, int? userId) async {
    try {
      final filename = path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          path,
          filename: filename,
        ),
      });
      final response = await _dio.post(
        'update_profile_pic',
        queryParameters: {'id': userId},
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (response.data['success']) {
        return DataSet.success(response.data['data']);
      } else {
        return DataSet.error(response.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> updateNotificationToken(String token) async {
    try {
      final response = await _dio.post(
        'update_notification_token',
        data: {
          'notification_token': token,
        },
      );
      if (response.data['success']) {
        return DataSet.success(response.data['data']);
      } else {
        return DataSet.error(response.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<Place> getPlace(double longitude, double latitude) async {
    try {
      _placeSearchToken.cancel('Canceled by new request');
      _placeSearchToken = CancelToken();
      final response = await _dio.post('get_place',
          cancelToken: _placeSearchToken,
          data: {
            'longitude': longitude.toString(),
            'latitude': latitude.toString()
          });
      Place place = Place.fromJson(response.data);
      return place;
    } on DioException catch (dioException) {
      throw ('dio exception: dioException');
    } catch (e) {
      rethrow;
    }
  }

  Future<DataSet<List<PlaceSimple>>> getPlaces(String type,
      {String? state, String? district}) async {
    try {
      final response = await _dio.post('get_places',
          data: {'type': type, 'state': state, 'district': district});
      if (response.statusCode == 200) {
        List<PlaceSimple> place = (response.data as List<dynamic>)
            .map((e) => PlaceSimple.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSet.success(place);
      }
      return DataSet.error(response.statusMessage);
    } on DioException catch (dioException) {
      return DataSet.error(dioException.message);
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  //Search place
  Future<List<dynamic>?> placeSearch(String query, bool limited, int offset,
      {double? latitude, double? longitude}) async {
    _placeSearchToken.cancel('');
    _placeSearchToken = CancelToken();
    try {
      final response = await _dio.post('place_search',
          data: {
            'query': query,
            'limited': limited,
            'offset': offset,
            'latitude': latitude,
            'longitude': longitude
          },
          cancelToken: _placeSearchToken);
      return response.data;
    } on DioException catch (dioError) {
      if (_placeSearchToken.isCancelled) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  //rent_category_posts   ....no
  NetworkHandle<AdRes> rentCatergoryPosts(
      String? category,
      String? keyword,
      String adType,
      int page,
      double latitude,
      double longitude,
      LocationType type,
      String location) async {
    try {
      final response = await _dio.post(
        'rent_category_posts',
        data: {
          'category': category,
          'keyword': keyword,
          'ad_type': adType,
          'latitude': latitude,
          'longitude': longitude,
          'location_type': type.toString().split('.')[1],
          'location': location,
          'page': page
        },
      );
      return right(AdRes.fromJson(response.data));
    } on DioException catch (e) {
      return left('Client error $e');
    } catch (e) {
      return left('Something went wrong: $e');
    }
  }

  NetworkHandle<List<SearchRentItem>> searchRentItem(
      String keyword, String adType) async {
    try {
      final response = await _dio.post('categories_search',
          data: {'keyword': keyword, 'ad_type': adType});
      final responseList = (response.data as List)
          .map((e) => SearchRentItem.fromJson(e))
          .toList();

      return right(List.from(responseList));
    } on DioException catch (e) {
      return left('Client error');
    } catch (e) {
      return left('Something went wron');
    }
  }

  NetworkHandle<AdRes> recommentedPosts(int page) async {
    try {
      final response = await _dio.post('recomented_posts', data: {
        'page': page,
      });
      return right(AdRes.fromJson(response.data));
    } on DioException catch (e) {
      return left('Client error');
    } catch (e) {
      return left('Something went wrong');
    }
  }

  NetworkHandle<AdRes> bestServiceProviders(LocationType locationType,
      String location, double latitude, double longitude, int page) async {
    try {
      final response = await _dio.post('best_service_providers', data: {
        'location_type': locationType.toString().split('.')[1],
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'page': page,
      });

      return right(AdRes.fromJson(response.data));
    } on DioException catch (e) {
      return left('Client error');
    } catch (e) {
      return left('Something went wrong');
    }
  }

  NetworkHandle<List<AdCategory>> adCatergoriesFor(
      String adType, String imageFor) async {
    //ad_post//ad_rent//ad_sevice
    try {
      final response = await _dio.post('ad_catergories_for',
          data: {'ad_type': adType, 'for': imageFor});

      return right((response.data as List<dynamic>)
          .map((e) => AdCategory.fromJson(e))
          .toList());
    } on DioException catch (e) {
      debugPrint(e.message);
      return left('Client error');
    } catch (e) {
      debugPrint(e.toString());
      return left('Something went wrong');
    }
  }

  //Post
  Future<DataSet<int>> createPost(String title, String description,
      String category, String adType, Map priceDetils,
      {int? adId, String? adStatus, int? adStage}) async {
    try {
      final res = await _dio.post('create_post', data: {
        'ad_id': adId,
        'title': title,
        'description': description,
        'category': category,
        'ad_type': adType,
        'ad_prices': priceDetils,
        'ad_status': adStatus,
        'ad_stage': adStage
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        return DataSet.success(res.data['ad_id']);
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<AdResponse?>> getRecentUnsavedAd() async {
    try {
      final res = await _dio.get('get_recent_unsaved_ad');
      if (res.statusCode == 200) {
        if ((res.data as Map<String, dynamic>).isNotEmpty) {
          return DataSet.success(AdResponse.fromJson(res.data));
        } else {
          return DataSet.success(null);
        }
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> deleteAdImage(int id) async {
    try {
      final res = await _dio.post('delete_ad_image', data: {'id': id});
      if (res.statusCode == 200 && res.data['success']) {
        if (res.data['success']) {
          return DataSet.success(res.data['message']);
        } else {
          return DataSet.error(res.data['message']);
        }
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> deleteAd(adId) async {
    try {
      final res = await _dio.post('/delete_ad', data: {'adId': adId});
      if (res.statusCode == 200) {
        return DataSet.success((res.data as Map)['message']);
      } else {
        return DataSet.error(res.statusMessage ?? '');
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> addPostAddress(
    int adId, {
    String? locality,
    String? district,
    String? state,
    String? adStatus,
    int? adStage,
    required String country,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await _dio.post('update_ad_address', data: {
        'ad_id': adId,
        'country': country,
        'state': state,
        'district': district,
        'locality': locality,
        'latitude': latitude,
        'longitude': longitude
      });
      if (res.statusCode == 200 && res.data['success']) {
        if (res.data['success']) {
          return DataSet.success(res.data['message']);
        } else {
          return DataSet.error(res.data['message']);
        }
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<AdResponse?>> getAdDetails(
    int adId,
  ) async {
    try {
      final res = await _dio.post('get_ad_details', data: {
        'ad_id': adId,
      });
      if (res.statusCode == 200) {
        return DataSet.success(AdResponse.fromJson(res.data));
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<List<AdResponse>>> myAds() async {
    try {
      final res = await _dio.get('my_ads');
      if (res.statusCode == 200 && res.data is List<dynamic>) {
        return DataSet.success((res.data as List<dynamic>)
            .map((e) => AdResponse.fromJson(e))
            .toList());
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> addToWishlist(int adId) async {
    try {
      final res = await _dio.post('add_to_wishlist', data: {'ad_id': adId});
      if (res.statusCode == 200) {
        return DataSet.success(res.data['message']);
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> changeOnlineStatus(int adId) async {
    try {
      final res =
          await _dio.post('change_online_status', data: {'ad_id': adId});
      if (res.statusCode == 200) {
        return DataSet.success(res.data['message']);
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<AdUser>> userWithAds(int? userId) async {
    try {
      final res = await _dio.post('user_with_ads', data: {'user_id': userId});
      if (res.statusCode == 200) {
        return DataSet.success(AdUser.fromJson(res.data));
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<List<AdResponse>>> userWishlists() async {
    try {
      final res = await _dio.get('user_wishlists');
      if (res.statusCode == 200) {
        return DataSet.success((res.data as List<dynamic>)
            .map((e) => AdResponse.fromJson(e))
            .toList());
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> removeWishlist(int adId) async {
    try {
      final res = await _dio.post('remove_wishlist', data: {'ad_id': adId});
      if (res.statusCode == 200) {
        return DataSet.success(res.data['message']);
      } else {
        return DataSet.error(res.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<Map>> priceCategories() async {
    try {
      final res = await _dio.get('price_categories');
      if (res.statusCode == 200) {
        return DataSet.success(res.data as Map);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(e.message.toString());
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<Map>> sendOtp(String mobile) async {
    final data = {'mobile': mobile};
    try {
      final res = await _dio.post('send_otp', data: data);
      if (res.statusCode == 200) {
        return DataSet.success(res.data as Map);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<Map>> verifyOto(String verificationId, int otp) async {
    final data = {'verificationId': verificationId, 'otp': otp};
    try {
      final res = await _dio.post('verify_otp', data: data);
      if (res.statusCode == 200) {
        return DataSet.success((res.data as Map)['data']);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<String>> verifyUpdateMobile(
      String verificationId, int otp) async {
    final data = {'verificationId': verificationId, 'otp': otp};
    try {
      final res = await _dio.post('verify_update_mobile', data: data);
      if (res.statusCode == 200) {
        return DataSet.success((res.data as Map)['message']);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  Future<DataSet<Map>> viewContact(int userId) async {
    final data = {'userId': userId};
    try {
      final res = await _dio.post('view_contact', data: data);
      if (res.statusCode == 200) {
        return DataSet.success((res.data as Map)['data']);
      } else {
        return DataSet.error(res.statusMessage);
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  //chat apis
  Future<Map<String, dynamic>> getChatsFromRoom(
      int? userId, int? authUserId) async {
    try {
      final response = await _dio.get('get_chat',
          queryParameters: {'authUserId': authUserId, 'otherUserId': userId});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.message};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<List> getAllChatRooms(int? userId) async {
    try {
      final response =
          await _dio.get('chat_rooms', queryParameters: {'authUserId': userId});
      return response.data['data'];
    } on DioException catch (e) {
      return ['Error'];
    } catch (e) {
      return ['Erro2+$e'];
    }
  }

  Future<int?> getChatRoomCount(int? userId) async {
    while (true) {
      try {
        final response = await _dio.get('unread_chat_room_count',
            queryParameters: {'authUserId': userId});
        return response.data['count'];
      } on DioException catch (e) {
        return 0;
      } catch (e) {
        return 0;
      }
      // await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<Map<String, dynamic>> isUserBlockedByOther(
      int? blockerId, int? blockedId) async {
    while (true) {
      try {
        final response = await _dio.get('is_blocked',
            queryParameters: {'blockerId': blockerId, 'blockedId': blockedId});
        return {
          'status': true,
          'result': response.data['blocked'],
        };
      } on DioException catch (e) {
        return {'status': false, 'message': 'Dio Exception: $e'};
      } catch (e) {
        return {'status': false, 'message': 'Error: $e'};
      }
    }
  }

  Future<bool> blockUser(int? authUserId, int? otherUserId) async {
    final data = {'authUserId': authUserId, 'otherUserId': otherUserId};
    try {
      final res = await _dio.post('block_user', data: data);
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unBlockUser(int? authUserId, int? otherUserId) async {
    final data = {'authUserId': authUserId, 'otherUserId': otherUserId};
    try {
      final res = await _dio.post('unblock_user', data: data);
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }
}
