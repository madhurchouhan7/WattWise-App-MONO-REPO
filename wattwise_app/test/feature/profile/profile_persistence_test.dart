import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wattwise_app/feature/profile/repository/profile_repository.dart';

void main() {
  test(
    'successful save persists and survives restart via cache hydration',
    () async {
      SharedPreferences.setMockInitialValues({});

      var networkOnline = true;
      var serverProfile = <String, dynamic>{
        'name': 'Asha Verma',
        'avatarUrl': 'https://example.com/old.png',
      };

      Future<Map<String, dynamic>> fetchRequest() async {
        if (!networkOnline) {
          throw const ProfileRequestException(
            message: 'offline',
            isRetryable: true,
          );
        }
        return {...serverProfile};
      }

      Future<Map<String, dynamic>> updateRequest(
        Map<String, dynamic> payload,
      ) async {
        if (!networkOnline) {
          throw const ProfileRequestException(
            message: 'offline',
            isRetryable: true,
          );
        }
        serverProfile = {
          ...serverProfile,
          'name': payload['name']?.toString() ?? '',
          'avatarUrl': payload['avatarUrl']?.toString() ?? '',
        };
        return {...serverProfile};
      }

      Future<void> cacheWriter(Map<String, dynamic> profile) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_profile_test-uid_json',
          jsonEncode(profile),
        );
      }

      Future<Map<String, dynamic>?> cacheReader() async {
        final prefs = await SharedPreferences.getInstance();
        final json = prefs.getString('user_profile_test-uid_json');
        if (json == null) return null;
        return jsonDecode(json) as Map<String, dynamic>;
      }

      final firstRunRepository = ProfileRepository(
        fetchProfileRequest: fetchRequest,
        updateProfileRequest: updateRequest,
        cacheWriter: cacheWriter,
        cacheReader: cacheReader,
      );

      final fetched = await firstRunRepository.fetchProfile();
      expect(fetched['name'], 'Asha Verma');

      final saved = await firstRunRepository.updateProfile(
        name: 'Asha Updated',
        avatarUrl: 'https://example.com/new.png',
      );

      expect(saved['name'], 'Asha Updated');
      expect(saved['avatarUrl'], 'https://example.com/new.png');

      networkOnline = false;
      final restartedRepository = ProfileRepository(
        fetchProfileRequest: fetchRequest,
        updateProfileRequest: updateRequest,
        cacheWriter: cacheWriter,
        cacheReader: cacheReader,
      );

      final hydrated = await restartedRepository.fetchProfile();
      expect(hydrated['name'], 'Asha Updated');
      expect(hydrated['avatarUrl'], 'https://example.com/new.png');
    },
  );
}
