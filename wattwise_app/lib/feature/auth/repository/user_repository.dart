import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/core/network/api_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(apiClient: ApiClient.instance);
});

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> saveGPSAddress({
    required double lat,
    required double lng,
  }) async {
    try {
      await _apiClient.put(
        '/users/me',
        data: {
          'address': {'lat': lat, 'lng': lng},
        },
      );
    } catch (e) {
      throw Exception('Failed to save GPS location: $e');
    }
  }

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
            'lat': ?lat,
            'lng': ?lng,
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

  Future<void> savePlanPreferences({
    required List<String> mainGoals,
    required String focusArea,
  }) async {
    try {
      await _apiClient.put(
        '/users/me',
        data: {
          'planPreferences': {'mainGoals': mainGoals, 'focusArea': focusArea},
        },
      );
    } catch (e) {
      throw Exception('Failed to save plan preferences: $e');
    }
  }

  Future<void> saveActivePlan(Map<String, dynamic> planData) async {
    try {
      await _apiClient.put('/users/me', data: {'activePlan': planData});
    } catch (e) {
      throw Exception('Failed to activate plan: $e');
    }
  }
}
