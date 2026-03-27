import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/profile/models/contact_support_models.dart';
import 'package:wattwise_app/feature/profile/provider/contact_support_provider.dart';
import 'package:wattwise_app/feature/profile/repository/support_repository.dart';

void main() {
  group('Contact support retry taxonomy', () {
    test('429 maps to retryable guidance and preserves draft', () async {
      final controller = _controllerWithError(
        const SupportSubmissionException(
          message: 'Too many requests. Slow down!',
          statusCode: 429,
          errorCode: 'RATE_LIMITED',
          isRetryable: true,
          retryAfterSeconds: 60,
        ),
      );

      final ok = await controller.submit();

      expect(ok, isFalse);
      expect(
        controller.state.status,
        ContactSupportSubmissionStatus.retryableError,
      );
      expect(controller.state.recoveryActionLabel, 'Retry');
      expect(controller.state.message, contains('retry after 60 seconds'));
      expect(controller.state.draft.category, 'billing');
    });

    test('503 maps to retryable guidance and preserves draft', () async {
      final controller = _controllerWithError(
        const SupportSubmissionException(
          message: 'Service unavailable.',
          statusCode: 503,
          errorCode: 'TEMPORARY_UNAVAILABLE',
          isRetryable: true,
        ),
      );

      final ok = await controller.submit();

      expect(ok, isFalse);
      expect(
        controller.state.status,
        ContactSupportSubmissionStatus.retryableError,
      );
      expect(controller.state.recoveryActionLabel, 'Retry');
      expect(controller.state.draft.contactName, 'Asha');
    });

    test('5xx maps to retryable guidance and preserves draft', () async {
      final controller = _controllerWithError(
        const SupportSubmissionException(
          message: 'Server error. Please try again later.',
          statusCode: 500,
          errorCode: 'INTERNAL_SERVER_ERROR',
          isRetryable: true,
        ),
      );

      final ok = await controller.submit();

      expect(ok, isFalse);
      expect(
        controller.state.status,
        ContactSupportSubmissionStatus.retryableError,
      );
      expect(controller.state.recoveryActionLabel, 'Retry');
      expect(controller.state.draft.message, contains('charged twice'));
    });
  });
}

ContactSupportController _controllerWithError(
  SupportSubmissionException error,
) {
  final controller = ContactSupportController(
    repository: _RetryErrorRepository(error),
  );

  controller
    ..updateCategory('billing')
    ..updateMessage(
      'I was charged twice for the same billing cycle this month.',
    )
    ..updateContactName('Asha')
    ..updateContactMethod(SupportContactMethod.email)
    ..updateEmail('asha@example.com')
    ..updateConsentAccepted(true);

  return controller;
}

class _RetryErrorRepository implements ISupportRepository {
  _RetryErrorRepository(this.error);

  final SupportSubmissionException error;

  @override
  Future<ContactSupportTicketResult> submitTicket(
    ContactSupportTicketRequest request,
  ) {
    throw error;
  }
}
