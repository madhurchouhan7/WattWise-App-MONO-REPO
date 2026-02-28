import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/core/network/api_client.dart';

final applianceRepositoryProvider = Provider<ApplianceRepository>((ref) {
  return ApplianceRepository(apiClient: ApiClient.instance);
});

class ApplianceRepository {
  final ApiClient _apiClient;

  ApplianceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> saveAppliances(List<Map<String, dynamic>> appliances) async {
    try {
      await _apiClient.put(
        '/users/me/appliances',
        data: {'appliances': appliances},
      );
    } catch (e) {
      throw Exception('Failed to save appliances: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAppliances() async {
    try {
      final response = await _apiClient.get('/users/me');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final appliances =
            response.data['data']['appliances'] as List<dynamic>?;
        if (appliances != null) {
          return List<Map<String, dynamic>>.from(appliances);
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appliances: $e');
    }
  }
}
