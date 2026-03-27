import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/profile/models/contact_support_models.dart';
import 'package:wattwise_app/feature/profile/provider/contact_support_provider.dart';
import 'package:wattwise_app/feature/profile/repository/support_repository.dart';
import 'package:wattwise_app/feature/profile/screens/contact_support_screen.dart';

void main() {
  testWidgets('required fields block submit and show inline guidance', (
    tester,
  ) async {
    final repository = _SpySupportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [supportRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ContactSupportScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('supportSubmitButton')));
    await tester.tap(find.byKey(const Key('supportSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Category is required.'), findsOneWidget);
    expect(find.text('Message is required.'), findsOneWidget);
    expect(find.text('Contact name is required.'), findsOneWidget);
    expect(repository.submitCalls, 0);
  });

  testWidgets('successful submit shows durable ticket reference', (
    tester,
  ) async {
    final repository = _SpySupportRepository(
      result: const ContactSupportTicketResult(
        ticketRef: 'SUP-20260327-TK9988',
        status: 'OPEN',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [supportRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ContactSupportScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supportCategoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Billing').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('supportMessageField')),
      'I was charged twice on my latest bill and need help.',
    );
    await tester.enterText(
      find.byKey(const Key('supportContactNameField')),
      'Asha',
    );
    await tester.enterText(
      find.byKey(const Key('supportEmailField')),
      'asha@example.com',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('supportSubmitButton')));
    await tester.tap(find.byKey(const Key('supportSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.submitCalls, 1);
    expect(find.text('SUP-20260327-TK9988'), findsOneWidget);
    expect(
      find.text('Support request submitted successfully.'),
      findsOneWidget,
    );
  });
}

class _SpySupportRepository implements ISupportRepository {
  _SpySupportRepository({this.result});

  int submitCalls = 0;
  final ContactSupportTicketResult? result;

  @override
  Future<ContactSupportTicketResult> submitTicket(
    ContactSupportTicketRequest request,
  ) async {
    submitCalls += 1;
    return result ??
        const ContactSupportTicketResult(
          ticketRef: 'SUP-20260327-DEFAULT2',
          status: 'OPEN',
        );
  }
}
