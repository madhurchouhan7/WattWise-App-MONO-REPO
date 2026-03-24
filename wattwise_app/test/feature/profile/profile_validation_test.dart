import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/profile/provider/profile_form_validators.dart';
import 'package:wattwise_app/feature/profile/provider/profile_provider.dart';
import 'package:wattwise_app/feature/profile/repository/profile_repository.dart';
import 'package:wattwise_app/feature/profile/screens/edit_profile_screen.dart';

void main() {
  test('validators enforce backend-aligned profile constraints', () {
    expect(ProfileFormValidators.validateName(''), 'Name is required.');
    expect(
      ProfileFormValidators.validateName('A'),
      'Name must be at least 2 characters.',
    );
    expect(
      ProfileFormValidators.validateAvatarUrl('ftp://example.com/a.png'),
      'Avatar URL must start with http:// or https://',
    );
    expect(ProfileFormValidators.validateName('Asha Verma'), isNull);
    expect(
      ProfileFormValidators.validateAvatarUrl('https://example.com/a.png'),
      isNull,
    );
  });

  testWidgets('invalid fields show inline errors before submit API call', (
    tester,
  ) async {
    final repository = _SpyProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'A');
    await tester.tap(find.text('Save Profile'));
    await tester.pump();

    expect(find.text('Name must be at least 2 characters.'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });

  testWidgets('server validation field errors are mapped inline', (
    tester,
  ) async {
    final repository = _SpyProfileRepository(
      validationError: const ProfileValidationException(
        message: 'Validation failed',
        fieldErrors: {'name': 'Name must be at least 2 characters.'},
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Asha Verma');
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(find.text('Validation failed'), findsOneWidget);
  });
}

class _SpyProfileRepository implements IProfileRepository {
  final ProfileValidationException? validationError;
  int updateCalls = 0;

  _SpyProfileRepository({this.validationError});

  @override
  Future<Map<String, dynamic>> fetchProfile({
    bool allowCacheFallback = true,
  }) async {
    return {
      'name': 'Asha Verma',
      'avatarUrl': 'https://example.com/avatar.png',
    };
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String avatarUrl,
  }) async {
    updateCalls += 1;
    if (validationError != null) {
      throw validationError!;
    }

    return {'name': name, 'avatarUrl': avatarUrl};
  }
}
