// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/ad_post_state.dart';
import 'package:elk/data/model/price_details.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/exception/dio_network_exception.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/network/entity/user_contact.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/network/entity/ads_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostCubit extends Cubit<AdPostState> {
  final UserRepository userRepository;
  final RentAdsRepository rentAdsRepository;
  final String apiKey;
  late final Dio _dio;

  AdPostCubit(this.userRepository, this.rentAdsRepository, this.apiKey)
      : super(AdPostInitialState()) {
    _dio = Dio()
      ..options.baseUrl = StringConstants.baseUrl
      ..options.headers = {'Authorization': 'Bearer $apiKey'}
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  final ValueNotifier<double> imageProgressNotifer = ValueNotifier(0);
  final ValueNotifier<List<Map<String, dynamic>>> imagesNotifer =
      ValueNotifier([]);
  final List<AdCategory> _rentList = [];
  final List<AdCategory> _serviceList = [];

  String _title = '';
  String _description = '';
  final Map _priceDetails = {};
  int? adId;
  AdResponse? adResponse;
  final List<AdPriceDetailResponse> adPriceList = [];

  Map get priceDetialsMap => _priceDetails;

  Future<void> iniiState() async {
    final res1 = await rentAdsRepository.adCatergoriesFor('rent', 'ad_post');
    final res2 = await rentAdsRepository.adCatergoriesFor('service', 'ad_post');
    if (res1.isRight() && res2.isRight()) {
      res1.match((l) {}, (r) {
        _rentList.addAll(r);
      });
      res2.match((l) {}, (r) {
        _serviceList.addAll(r);
      });
      emit(AdPostLoadState(List.from(_rentList), List.from(_serviceList)));
    }
  }

  Future<void> loadRecentAd(AdResponse adResponse) async {
    this.adResponse = adResponse;
    adId = adResponse.adId;
    _title = adResponse.title;
    _description = adResponse.description;
    //prices
    for (var element in adResponse.adPriceDetails) {
      adPriceList.add(element);
      _priceDetails[element.rentDuration] = element.rentPrice;
    }
    //images
    final List<Map<String, dynamic>> imagesList = [];
    for (var element in adResponse.adImages) {
      imagesList
          .add({'id': element.id, 'type': 'network', 'path': element.image});
    }
    imagesNotifer.value = imagesList;
  }

  void updateUploadedImage(List<AdImageResponse> adImages) {
    final List<Map<String, dynamic>> imagesList = [];
    for (var element in adImages) {
      imagesList
          .add({'id': element.id, 'type': 'network', 'path': element.image});
    }
    imagesNotifer.value = imagesList;
  }

  addPriceMap(PriceDetails priceDetail) {
    _priceDetails[priceDetail.priceType] = priceDetail.price;
  }

  deletePriceMap(deleteKey) {
    _priceDetails.removeWhere((key, value) => key == deleteKey);
  }

  Future<DataSet<AdResponse?>> fetchRecentAd() async {
    final res = await rentAdsRepository.getRecentUnsavedPost();
    return res;
  }

  changeTitle(String title) {
    _title = title;
  }

  changeDescription(String description) {
    _description = description;
  }

  Future<DataSet<int>> createPost(String category, String adType) async {
    final res = await rentAdsRepository.createPost(
        _title, _description, category, adType, _priceDetails, adId,
        adSatge: adResponse?.adStage, adStatus: adResponse?.adStatus);
    return res;
  }

  void updateAdId(int adId) {
    this.adId = adId;
  }

  void updateImaegStream(String type, String path) {
    List<Map<String, dynamic>> currentList = List.from(imagesNotifer.value);
    currentList.add({'uploadStatus': 0, 'type': type, 'path': path});
    imagesNotifer.value = currentList;
  }

  void updateMultiImages(String type, List<String> paths) {
    List<Map<String, dynamic>> currentList = List.from(imagesNotifer.value);
    for (var element in paths) {
      currentList.add({'uploadStatus': 0, 'type': type, 'path': element});
    }
    imagesNotifer.value = currentList;
  }

  void deleteImage(String type, String path) {
    List<Map<String, dynamic>> currentList = List.from(imagesNotifer.value);
    currentList.removeWhere(
        (element) => element['type'] == type && element['path'] == path);
    imagesNotifer.value = currentList;
  }

  Future<DataSet<String>> uploadAdImage() async {
    List<Map<String, dynamic>> paths = imagesNotifer.value;
    try {
      final formData = FormData();
      for (var path in paths) {
        if (!path['path'].startsWith("http")) {
          final filename = path['path'].split('/').last;
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              path['path'],
              filename: filename,
            ),
          ));
        }
      }

      final response = await _dio.post(
        'upload_ad_image',
        queryParameters: {
          'ad_id': adId,
          'ad_stage': adResponse != null ? adResponse!.adStage.toString() : '',
          'ad_status': adResponse != null ? adResponse!.adStatus : '',
        },
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.data['success']) {
        return DataSet.success(response.data['data'].toString());
      } else {
        return DataSet.error(response.data['message']);
      }
    } on DioException catch (e) {
      return DataSet.error(DioNetworkEception.handeleError(e));
    } catch (e) {
      return DataSet.error(e.toString());
    }
  }

  // Future<DataSet<String>> uploadAdImage() async {
  //   List<Map<String, dynamic>> paths = imagesNotifer.value;
  //   if (paths.any((element) => element['type'] == 'local')) {
  //     final formData = FormData();
  //     formData.fields.add(MapEntry('ad_id', adId.toString()));
  //     formData.fields.add(MapEntry(
  //         'ad_status', adResponse != null ? adResponse!.adStatus : ''));
  //     formData.fields.add(MapEntry('ad_stage',
  //         adResponse != null ? adResponse!.adStage.toString() : ''));
  //     for (int i = 0; i < paths.length; i++) {
  //       if (paths[i]['type'] == 'local') {
  //         String path = paths[i]['path'];
  //         formData.files
  //             .add(MapEntry('images[]', await MultipartFile.fromFile(path)));
  //       }
  //     }
  //     //test

  //     try {
  //       final res = await _dio.post('upload_ad_image', data: formData,
  //           onSendProgress: (count, total) async {
  //         final progress = (count / total);
  //         debugPrint(' totlal : $total , count : $count, progress: $progress');
  //         if (progress < 1.0) {
  //           imageProgressNotifer.value = progress;
  //         } else {
  //           imageProgressNotifer.value = 0.0;
  //         }
  //       });
  //       if (res.statusCode == 200 && res.data['success'] == true) {
  //         for (var element in paths) {
  //           element['uploadStatus'] = 1;
  //         }
  //         updateUploadedImage(List.from((res.data['data'] as List<dynamic>)
  //             .map((e) => AdImageResponse.fromJson(e))
  //             .toList()));
  //         return DataSet.success(res.data['message']);
  //       } else {
  //         return DataSet.error(res.data['message']);
  //       }
  //     } on DioException catch (e) {
  //       return DataSet.error(DioNetworkEception.handeleError(e));
  //     } catch (e) {
  //       return DataSet.error(e.toString());
  //     }
  //   } else {
  //     return DataSet.success('Upload success');
  //   }
  // }

  Future<DataSet<String?>> deleteAdImage(int id) async {
    final res = await rentAdsRepository.deleteAdImage(id);
    return res;
  }
}
