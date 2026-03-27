import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/profile/models/contact_support_models.dart';
import 'package:wattwise_app/feature/profile/provider/contact_support_provider.dart';
import 'package:wattwise_app/feature/profile/repository/support_repository.dart';

void main() {
  test('validation blocks submit and keeps draft intact', () async {
    final repository = _FakeSupportRepository();
    final controller = ContactSupportController(repository: repository);

    controller
      ..updateCategory('billing')
      ..updateMessage('Too short')
      ..updateContactName('Asha')
      ..updateContactMethod(SupportContactMethod.email)
      ..updateEmail('asha@example.com')
      ..updateConsentAccepted(true);

    final ok = await controller.submit();

    expect(ok, isFalse);
    expect(
      controller.state.status,
      ContactSupportSubmissionStatus.validationError,
    );
    expect(
      controller.state.fieldErrors['message'],
      'Message must be at least 10 characters.',
    );
    expect(controller.state.draft.message, 'Too short');
    expect(repository.submitCalls, 0);
  });

  test('success exposes durable ticketRef from backend payload', () async {
    final repository = _FakeSupportRepository(
      nextResult: const ContactSupportTicketResult(
        ticketRef: 'SUP-20260327-AB12CD',
        status: 'OPEN',
        requestId: 'req-support-123',
      ),
    );
    final controller = ContactSupportController(repository: repository);

    controller
      ..updateCategory('billing')
      ..updateMessage('I was charged twice on my latest bill statement.')
      ..updateContactName('Asha')
      ..updateContactMethod(SupportContactMethod.email)
      ..updateEmail('asha@example.com')
      ..updateConsentAccepted(true);

    final ok = await controller.submit();

    expect(ok, isTrue);
    expect(controller.state.status, ContactSupportSubmissionStatus.success);
    expect(controller.state.ticketRef, 'SUP-20260327-AB12CD');
    expect(controller.state.requestId, 'req-support-123');
    expect(repository.submitCalls, 1);
  });

  test('retryable failure preserves draft and can recover on retry', () async {
    final repository = _FakeSupportRepository(
      nextError: const SupportSubmissionException(
        message: 'Support service is temporarily unavailable. Please retry.',
        statusCode: 503,
        errorCode: 'TEMPORARY_UNAVAILABLE',
        isRetryable: true,
        retryAfterSeconds: 30,
      ),
      nextResult: const ContactSupportTicketResult(
        ticketRef: 'SUP-20260327-EE9988',
        status: 'OPEN',
      ),
    );
    final controller = ContactSupportController(repository: repository);

    controller
      ..updateCategory('technical')
      ..updateMessage('The app cannot load my latest meter readings right now.')
      ..updateContactName('Asha')
      ..updateContactMethod(SupportContactMethod.email)
      ..updateEmail('asha@example.com')
      ..updateConsentAccepted(true);

    final firstAttempt = await controller.submit();

    expect(firstAttempt, isFalse);
    expect(
      controller.state.status,
      ContactSupportSubmissionStatus.retryableError,
    );
    expect(controller.state.draft.message, contains('latest meter readings'));
    expect(controller.state.message, contains('retry after 30 seconds'));

    final secondAttempt = await controller.retry();

    expect(secondAttempt, isTrue);
    expect(controller.state.status, ContactSupportSubmissionStatus.success);
    expect(controller.state.ticketRef, 'SUP-20260327-EE9988');
  });
}

class _FakeSupportRepository implements ISupportRepository {
  _FakeSupportRepository({this.nextError, this.nextResult});

  SupportSubmissionException? nextError;
  ContactSupportTicketResult? nextResult;
  int submitCalls = 0;

  @override
  Future<ContactSupportTicketResult> submitTicket(
    ContactSupportTicketRequest request,
  ) async {
    submitCalls += 1;
    if (nextError != null) {
      final error = nextError!;
      nextError = null;
      throw error;
    }

    return nextResult ??
        const ContactSupportTicketResult(
          ticketRef: 'SUP-20260327-DEFAULT1',
          status: 'OPEN',
        );
  }
}
