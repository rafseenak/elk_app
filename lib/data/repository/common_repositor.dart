import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:get_it/get_it.dart';

class CommonRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<DataSet<Map>> priceCategories() async {
    final res = await _apiClient.priceCategories();
    return res;
  }
}
