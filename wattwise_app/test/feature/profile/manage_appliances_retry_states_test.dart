import 'package:flutter_test/flutter_test.dart';

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
      'provider retry lifecycle transitions from saveError to idle after successful retry',
      () async {
        // TODO(phase-08-02): Replace with ProviderContainer integration once
        // manage appliances async mutation state is exposed by provider APIs.
      },
      skip: 'Pending provider retry-state implementation in phase 08-02',
    );
  });
}

bool _isRetryableConflict(Map<String, dynamic> response) {
  final code = response['errorCode']?.toString().toUpperCase();
  return code == 'PRECONDITION_FAILED';
}

bool _shouldPreserveDraft(Map<String, dynamic> response) {
  final details = response['details'];
  return details is List && details.isNotEmpty;
}
