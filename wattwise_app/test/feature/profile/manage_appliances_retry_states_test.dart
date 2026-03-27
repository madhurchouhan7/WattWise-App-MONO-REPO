import 'package:wattwise_app/feature/on_boarding/repository/appliance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/core/network/api_client.dart';
import 'package:wattwise_app/feature/profile/provider/manage_appliances_provider.dart';
import 'package:dio/dio.dart';

void main() {
  group('Manage appliances retry and conflict states (APP-04)', () {
    test(
      'conflict (412) envelope is treated as retryable with preserved draft',
      () {
        final conflictResponse = {
          'success': false,
          'message': 'Precondition failed: stale appliance revision.',
          'errorCode': 'PRECONDITION_FAILED',
          'details': [
            {
              'path': 'revision',
              'message':
                  'Client revision does not match latest appliance state.',
            },
          ],
        };

        final isRetryable = _isRetryableConflict(conflictResponse);
        final shouldPreserveDraft = _shouldPreserveDraft(conflictResponse);

        expect(isRetryable, isTrue);
        expect(shouldPreserveDraft, isTrue);
      },
    );

    test(
      'provider marks stale-write as conflict with reload guidance',
      () async {
        final repo = _FakeApplianceRepository();
        final controller = ManageApplianceMutationController(repository: repo);
        final draft = {
          'applianceId': 'ac-1',
          'title': 'Air Conditioner',
          'category': 'cooling',
        };

        repo.nextError = ApplianceMutationException(
          type: ApplianceMutationErrorType.conflict,
          message: 'Precondition failed: stale appliance revision.',
          errorCode: 'PRECONDITION_FAILED',
          details: const [
            {
              'path': 'revision',
              'message':
                  'Client revision does not match latest appliance state.',
            },
          ],
        );

        final ok = await controller.saveApplianceDraft(
          applianceId: 'ac-1',
          draft: draft,
          expectedVersion: '3',
        );

        expect(ok, isFalse);
        expect(controller.state.status, ManageApplianceMutationStatus.conflict);
        expect(controller.state.recoveryActionLabel, 'Reload latest');
        expect(
          controller.state.retryHint,
          contains('reload latest appliance state'),
        );
        expect(controller.state.preservedDraft, draft);
      },
    );

    test(
      'provider retry lifecycle transitions from retryable error to success',
      () async {
        final repo = _FakeApplianceRepository();
        final controller = ManageApplianceMutationController(repository: repo);
        final draft = {
          'applianceId': 'ac-1',
          'title': 'Air Conditioner',
          'category': 'cooling',
        };

        repo.nextError = ApplianceMutationException(
          type: ApplianceMutationErrorType.retryable,
          message: 'Temporary upstream failure.',
          errorCode: 'UPSTREAM_TIMEOUT',
        );

        final firstAttempt = await controller.saveApplianceDraft(
          applianceId: 'ac-1',
          draft: draft,
          expectedVersion: '4',
        );
        expect(firstAttempt, isFalse);
        expect(
          controller.state.status,
          ManageApplianceMutationStatus.retryableError,
        );
        expect(controller.state.recoveryActionLabel, 'Retry');
        expect(controller.state.preservedDraft, draft);

        repo.nextError = null;
        final secondAttempt = await controller.retry();

        expect(secondAttempt, isTrue);
        expect(controller.state.status, ManageApplianceMutationStatus.success);
        expect(controller.state.preservedDraft, isNull);
        expect(controller.state.retryHint, contains('saved successfully'));
      },
    );

    test('provider reset returns mutation state to idle', () {
      final repo = _FakeApplianceRepository();
      final controller = ManageApplianceMutationController(repository: repo);

      controller.reset();

      expect(controller.state.status, ManageApplianceMutationStatus.idle);
      expect(controller.state.preservedDraft, isNull);
      expect(controller.state.retryHint, isEmpty);
    });

    test(
      'delete request sends body._expectedVersion when precondition token exists',
      () async {
        final client = _CapturingApiClient();
        final repository = ApplianceRepository(apiClient: client);

        await repository.deleteAppliance(
          applianceId: 'ac-1',
          expectedVersion: '7',
        );

        expect(client.lastRequestOptions?.method, 'DELETE');
        expect(client.lastRequestOptions?.path, '/appliances/ac-1');
        expect(client.lastRequestOptions?.data, {'_expectedVersion': '7'});
      },
    );

    test('update expected-version fallback maps backend __v token', () async {
      final client = _CapturingApiClient();
      final repository = ApplianceRepository(apiClient: client);

      await repository.updateAppliance(
        applianceId: 'ac-1',
        payload: {'applianceId': 'ac-1', 'title': 'Air Conditioner', '__v': 11},
      );

      expect(client.lastRequestOptions?.method, 'PATCH');
      expect(
        (client.lastRequestOptions?.data as Map<String, dynamic>?),
        isNotNull,
      );
      final payload = (client.lastRequestOptions!.data as Map<String, dynamic>);
      expect(payload['_expectedVersion'], '11');
    });
  });
}

class _FakeApplianceRepository extends ApplianceRepository {
  _FakeApplianceRepository() : super(apiClient: ApiClient.instance);

  ApplianceMutationException? nextError;

  @override
  Future<Map<String, dynamic>> createAppliance({
    required Map<String, dynamic> payload,
  }) async {
    if (nextError != null) {
      final error = nextError!;
      nextError = null;
      throw error;
    }
    return {'success': true, 'data': payload};
  }

  @override
  Future<Map<String, dynamic>> updateAppliance({
    required String applianceId,
    required Map<String, dynamic> payload,
    String? expectedVersion,
  }) async {
    if (nextError != null) {
      final error = nextError!;
      nextError = null;
      throw error;
    }
    return {'success': true, 'data': payload};
  }

  @override
  Future<Map<String, dynamic>> deleteAppliance({
    required String applianceId,
    String? expectedVersion,
  }) async {
    if (nextError != null) {
      final error = nextError!;
      nextError = null;
      throw error;
    }
    return {'success': true};
  }
}

bool _isRetryableConflict(Map<String, dynamic> response) {
  final code = response['errorCode']?.toString().toUpperCase();
  return code == 'PRECONDITION_FAILED';
}

bool _shouldPreserveDraft(Map<String, dynamic> response) {
  final details = response['details'];
  return details is List && details.isNotEmpty;
}

class _CapturingApiClient implements ApiClient {
  _CapturingApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequestOptions = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const {'success': true},
            ),
          );
        },
      ),
    );
  }

  final Dio _dio = Dio();

  RequestOptions? lastRequestOptions;

  @override
  Dio get dio => _dio;

  @override
  Future<Response<T>> delete<T>(String path, {Options? options}) {
    return _dio.delete<T>(path, options: options);
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParams, options: options);
  }

  @override
  void init() {}

  @override
  Future<Response<T>> patch<T>(String path, {data, Options? options}) {
    return _dio.patch<T>(path, data: data, options: options);
  }

  @override
  Future<Response<T>> post<T>(String path, {data, Options? options}) {
    return _dio.post<T>(path, data: data, options: options);
  }

  @override
  Future<Response<T>> put<T>(String path, {data, Options? options}) {
    return _dio.put<T>(path, data: data, options: options);
  }
}
