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
      // Map UI category labels to strict backend MongoDB Enums
      final mappedAppliances = appliances.map((app) {
        final Map<String, dynamic> modifiedApp = Map.from(app);
        switch (modifiedApp['category'].toString().toUpperCase()) {
          case 'COOLING':
            modifiedApp['category'] = 'cooling';
            break;
          case 'HEATING':
            modifiedApp['category'] = 'heating';
            break;
          case 'LIGHTING':
            modifiedApp['category'] = 'lighting';
            break;
          case 'KITCHEN':
          case 'ALWAYS ON': // Refrigerator mapping
            modifiedApp['category'] = 'kitchen';
            break;
          case 'LAUNDRY':
          case 'OCCASIONAL USE': // Washing Machine mapping
            modifiedApp['category'] = 'laundry';
            break;
          case 'COMPUTING':
            modifiedApp['category'] = 'computing';
            break;
          case 'ENTERTAINMENT':
            modifiedApp['category'] = 'entertainment';
            break;
          case 'CHARGING':
            modifiedApp['category'] = 'charging';
            break;
          case 'CLEANING':
            modifiedApp['category'] = 'cleaning';
            break;
          default:
            // Ensures safety fallback for backend validation if new UI categories are added later
            modifiedApp['category'] = 'other';
        }
        return modifiedApp;
      }).toList();

      await _apiClient.post(
        '/appliances/bulk',
        data: {'appliances': mappedAppliances},
      );
    } catch (e) {
      throw Exception('Failed to save appliances: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAppliances() async {
    try {
      // Use the dedicated appliances endpoint, not the user profile
      final response = await _apiClient.get('/appliances');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final appliancesList = response.data['data'] as List<dynamic>;
        return List<Map<String, dynamic>>.from(appliancesList);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appliances: $e');
    }
  }
}
