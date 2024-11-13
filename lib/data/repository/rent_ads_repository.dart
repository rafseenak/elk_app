import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/network/entity/ads_category.dart';
import 'package:elk/network/entity/search_rent_item.dart';
import 'package:get_it/get_it.dart';

class RentAdsRepository {
  RentAdsRepository();
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  NetworkHandle<AdRes> rentCategoryPosts(
      String? category,
      String? keyword,
      String adType,
      int page,
      double latitude,
      double longitude,
      LocationType locationType,
      String location) async {
    final adRes = await _apiClient.rentCatergoryPosts(category, keyword, adType,
        page, latitude, longitude, locationType, location);
    return adRes;
  }

  NetworkHandle<List<SearchRentItem>> searchRentItem(
      String keyword, String adType) async {
    final adRes = await _apiClient.searchRentItem(keyword, adType);
    return adRes;
  }

  NetworkHandle<AdRes> recometedPosts(int page) async {
    final adRes = await _apiClient.recommentedPosts(page);
    return adRes;
  }

  Future<DataSet<String>> changeOnlineStatus(int adId) async {
    final adRes = await _apiClient.changeOnlineStatus(adId);
    return adRes;
  }

  NetworkHandle<AdRes> bestServiceProviders(
    LocationType locationType,
    String location,
    double latitude,
    double longitude,
    int page,
  ) async {
    final adRes = await _apiClient.bestServiceProviders(
        locationType, location, latitude, longitude, page);
    return adRes;
  }

  NetworkHandle<List<AdCategory>> adCatergoriesFor(
      String adType, String imageFor) async {
    final adRes = await _apiClient.adCatergoriesFor(adType, imageFor);
    return adRes;
  }

  Future<DataSet<int>> createPost(String title, String description,
      String category, String adType, Map priceDetils, int? adId,
      {String? adStatus, int? adSatge}) async {
    final res = await _apiClient.createPost(
        title, description, category, adType, priceDetils,
        adStage: adSatge, adStatus: adStatus, adId: adId);
    return res;
  }

  Future<DataSet<AdResponse?>> getRecentUnsavedPost() async {
    final res = await _apiClient.getRecentUnsavedAd();
    return res;
  }

  Future<DataSet<String?>> deleteAdImage(int id) async {
    final res = await _apiClient.deleteAdImage(id);
    return res;
  }

  Future<DataSet<String>> deleteAd(int adId) async {
    final res = await _apiClient.deleteAd(adId);
    return res;
  }

  Future<DataSet<String?>> adPostAddress(int adId, Location location,
      {int? adStage, String? adStatus}) async {
    final res = await _apiClient.addPostAddress(adId,
        country: location.country,
        latitude: location.latitude,
        longitude: location.longitude,
        state: location.state,
        adStage: adStage,
        district: location.district,
        locality: location.locality);
    return res;
  }

  Future<DataSet<AdResponse?>> getAdDetails(int adId) async {
    final res = await _apiClient.getAdDetails(adId);
    return res;
  }

  Future<DataSet<List<AdResponse>>> myAds() async {
    final res = await _apiClient.myAds();
    return res;
  }

  Future<DataSet<String>> addToWishlist(int adId) async {
    final res = await _apiClient.addToWishlist(adId);
    return res;
  }
}
