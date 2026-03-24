import 'package:dio/dio.dart';
import 'package:wattwise_app/core/network/api_client.dart';
import 'package:wattwise_app/core/network/api_exception.dart';
import 'package:wattwise_app/feature/auth/repository/auth_repository.dart';

abstract class IProfileRepository {
  Future<Map<String, dynamic>> fetchProfile({bool allowCacheFallback = true});

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String avatarUrl,
  });
}

class ProfileValidationException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;

  const ProfileValidationException({
    required this.message,
    required this.fieldErrors,
  });

  @override
  String toString() => 'ProfileValidationException: $message';
}

class ProfileRequestException implements Exception {
  final String message;
  final bool isRetryable;

  const ProfileRequestException({
    required this.message,
    required this.isRetryable,
  });

  @override
  String toString() => 'ProfileRequestException: $message';
}

class ProfileRepository implements IProfileRepository {
  final AuthRepository? _authRepository;
  final Future<Map<String, dynamic>> Function()? _fetchProfileRequest;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> payload)?
  _updateProfileRequest;
  final Future<void> Function(Map<String, dynamic> profile)? _cacheWriter;
  final Future<Map<String, dynamic>?> Function()? _cacheReader;

  ProfileRepository({
    AuthRepository? authRepository,
    Future<Map<String, dynamic>> Function()? fetchProfileRequest,
    Future<Map<String, dynamic>> Function(Map<String, dynamic> payload)?
    updateProfileRequest,
    Future<void> Function(Map<String, dynamic> profile)? cacheWriter,
    Future<Map<String, dynamic>?> Function()? cacheReader,
  }) : _authRepository = authRepository,
       _fetchProfileRequest = fetchProfileRequest,
       _updateProfileRequest = updateProfileRequest,
       _cacheWriter = cacheWriter,
       _cacheReader = cacheReader;

  @override
  Future<Map<String, dynamic>> fetchProfile({
    bool allowCacheFallback = true,
  }) async {
    try {
      final profile = _normalizeProfile(
        _fetchProfileRequest != null
            ? await _fetchProfileRequest.call()
            : await _defaultFetchProfileRequest(),
      );
      await _writeProfileCache(profile);
      return profile;
    } catch (error) {
      if (allowCacheFallback) {
        final cached = await _readProfileCache();
        if (cached != null) {
          return _normalizeProfile(cached);
        }
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'avatarUrl': avatarUrl.trim(),
    };

    try {
      final updated = _normalizeProfile(
        _updateProfileRequest != null
            ? await _updateProfileRequest.call(payload)
            : await _defaultUpdateProfileRequest(payload),
      );
      await _writeProfileCache(updated);
      return updated;
    } catch (error) {
      if (error is DioException && error.error is ApiException) {
        final apiError = error.error as ApiException;
        final fieldErrors = _extractFieldErrors(apiError.data);
        if (apiError.statusCode == 400 && fieldErrors.isNotEmpty) {
          throw ProfileValidationException(
            message: apiError.message,
            fieldErrors: fieldErrors,
          );
        }

        throw ProfileRequestException(
          message: apiError.message,
          isRetryable:
              apiError.isNetworkError ||
              apiError.isServerError ||
              apiError.statusCode == 409,
        );
      }

      if (error is ProfileValidationException ||
          error is ProfileRequestException) {
        rethrow;
      }

      throw const ProfileRequestException(
        message:
            'We could not update your profile right now. Check your connection, review highlighted fields, and try again.',
        isRetryable: true,
      );
    }
  }

  Future<Map<String, dynamic>> _defaultFetchProfileRequest() async {
    final response = await ApiClient.instance.get('/users/me');
    return _extractEnvelopeData(response.data);
  }

  Future<Map<String, dynamic>> _defaultUpdateProfileRequest(
    Map<String, dynamic> payload,
  ) async {
    final response = await ApiClient.instance.put('/users/me', data: payload);
    return _extractEnvelopeData(response.data);
  }

  Future<void> _writeProfileCache(Map<String, dynamic> profile) async {
    if (_cacheWriter != null) {
      await _cacheWriter.call(profile);
      return;
    }
    await (_authRepository ?? AuthRepository()).writeProfileCacheForCurrentUser(
      profile,
    );
  }

  Future<Map<String, dynamic>?> _readProfileCache() async {
    if (_cacheReader != null) {
      return _cacheReader.call();
    }
    return (_authRepository ?? AuthRepository())
        .readProfileCacheForCurrentUser();
  }

  Map<String, dynamic> _extractEnvelopeData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ProfileRequestException(
      message: 'Unexpected profile response from server.',
      isRetryable: false,
    );
  }

  Map<String, dynamic> _normalizeProfile(Map<String, dynamic> profile) {
    final normalized = <String, dynamic>{...profile};
    normalized['name'] = (profile['name'] ?? profile['displayName'] ?? '')
        .toString();
    normalized['avatarUrl'] =
        (profile['avatarUrl'] ?? profile['photoUrl'] ?? '').toString();
    return normalized;
  }

  Map<String, String> _extractFieldErrors(dynamic errorData) {
    final errors = <String, String>{};

    if (errorData is! Map<String, dynamic>) {
      return errors;
    }

    final details = errorData['details'];
    if (details is List) {
      for (final item in details) {
        if (item is Map<String, dynamic>) {
          final field = item['path']?.toString();
          final message = item['message']?.toString();
          if (field != null && message != null && field.isNotEmpty) {
            errors[field] = message;
          }
        }
      }
    }

    final envelopeErrors = errorData['errors'];
    if (envelopeErrors is List) {
      for (final item in envelopeErrors) {
        if (item is Map<String, dynamic>) {
          final field = item['field']?.toString();
          final message = item['message']?.toString();
          if (field != null && message != null && field.isNotEmpty) {
            errors[field] = message;
          }
        }
      }
    }

    return errors;
  }
}
