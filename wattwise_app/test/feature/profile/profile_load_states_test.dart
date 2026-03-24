import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/profile/provider/profile_provider.dart';
import 'package:wattwise_app/feature/profile/repository/profile_repository.dart';

void main() {
  test('profile retry recovers from transient load failure', () async {
    final repository = _FakeProfileRepository(
      profile: {
        'name': 'Asha Verma',
        'avatarUrl': 'https://example.com/avatar.png',
      },
      failFetchCount: 1,
    );
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(profileProvider.future),
      throwsA(isA<ProfileRequestException>()),
    );

    expect(container.read(profileProvider).hasError, isTrue);

    await container.read(profileProvider.notifier).retryFetch();
    final recovered = await container.read(profileProvider.future);
    expect(recovered['name'], 'Asha Verma');
  });

  test('save retry keeps form draft and succeeds on second attempt', () async {
    final repository = _FakeProfileRepository(
      profile: {
        'name': 'Asha Verma',
        'avatarUrl': 'https://example.com/avatar.png',
      },
      failUpdateCount: 1,
    );
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(profileProvider.future);
    final notifier = container.read(profileProvider.notifier);

    notifier.setDraftName('Asha Updated');
    await notifier.saveProfile();

    final failedOperation = container.read(profileOperationProvider);
    expect(failedOperation.hasSaveError, isTrue);
    expect(container.read(profileDraftProvider).name, 'Asha Updated');

    await notifier.retrySave();
    final savedProfile = await container.read(profileProvider.future);
    expect(savedProfile['name'], 'Asha Updated');
    expect(container.read(profileOperationProvider).hasSaveSuccess, isTrue);
  });
}

class _FakeProfileRepository implements IProfileRepository {
  Map<String, dynamic> profile;
  int failFetchCount;
  int failUpdateCount;

  _FakeProfileRepository({
    required this.profile,
    this.failFetchCount = 0,
    this.failUpdateCount = 0,
  });

  @override
  Future<Map<String, dynamic>> fetchProfile({
    bool allowCacheFallback = true,
  }) async {
    if (failFetchCount > 0) {
      failFetchCount -= 1;
      throw const ProfileRequestException(
        message: 'Temporary fetch failure',
        isRetryable: true,
      );
    }
    return {...profile};
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String avatarUrl,
  }) async {
    if (failUpdateCount > 0) {
      failUpdateCount -= 1;
      throw const ProfileRequestException(
        message: 'Temporary save failure',
        isRetryable: true,
      );
    }

    profile = {...profile, 'name': name, 'avatarUrl': avatarUrl};
    return {...profile};
  }
}
