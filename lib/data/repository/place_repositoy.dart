import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/place.dart';
import 'package:elk/network/entity/place_entity.dart';
import 'package:elk/network/entity/place_search.dart';
import 'package:get_it/get_it.dart';

class PlaceRepository {
  PlaceRepository();
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<Place?> getPlace(double longitude, double latitude) async {
    Place? place = await _apiClient.getPlace(longitude, latitude);
    return place;
  }

  Future<List<PlaceSearch>> searchPlace(String query, bool limited, int offset,
      {double? latitude, double? longitude}) async {
    List<PlaceSearch> places = [];
    final responseData = await _apiClient.placeSearch(query, limited, offset,
        longitude: longitude, latitude: latitude);
    if (responseData != null) {
      for (var json in responseData) {
        places.add(PlaceSearch.fromJson(json));
      }
    }
    return places;
  }

  Future<DataSet<List<PlaceSimple>>> getPlaces(String type,
      {String? state, String? district}) async {
    final res =
        await _apiClient.getPlaces(type, state: state, district: district);
    return res;
  }
}
