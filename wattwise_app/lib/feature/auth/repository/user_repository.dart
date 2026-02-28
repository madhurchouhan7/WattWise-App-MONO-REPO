import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/core/network/api_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(apiClient: ApiClient.instance);
});

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> saveAddress({
    required String state,
    required String city,
    required String discom,
    double? lat,
    double? lng,
  }) async {
    try {
      await _apiClient.put(
        '/users/me',
        data: {
          'address': {
            'state': state,
            'city': city,
            'discom': discom,
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
          },
        },
      );
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }

  Future<void> saveHouseholdDetails({
    required int peopleCount,
    String? familyType,
    String? houseType,
  }) async {
    try {
      await _apiClient.put(
        '/users/me',
        data: {
          'household': {
            'peopleCount': peopleCount,
            'familyType': familyType,
            'houseType': houseType,
          },
        },
      );
    } catch (e) {
      throw Exception('Failed to save household details: $e');
    }
  }
}
