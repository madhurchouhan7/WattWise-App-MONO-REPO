import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/core/colors.dart';
import 'package:wattwise_app/feature/profile/models/contact_support_models.dart';
import 'package:wattwise_app/feature/profile/provider/contact_support_provider.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final _messageController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactSupportProvider);
    final notifier = ref.read(contactSupportProvider.notifier);
    final draft = state.draft;

    _syncControllers(draft);

    final isSubmitting =
        state.status == ContactSupportSubmissionStatus.submitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tell us what happened and we will create a trackable support ticket.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('supportCategoryField'),
              initialValue: draft.category.isEmpty ? null : draft.category,
              decoration: InputDecoration(
                labelText: 'Category',
                errorText: state.fieldErrors['category'],
              ),
              items: const [
                DropdownMenuItem(value: 'billing', child: Text('Billing')),
                DropdownMenuItem(value: 'outage', child: Text('Power Outage')),
                DropdownMenuItem(value: 'technical', child: Text('Technical')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) => notifier.updateCategory(value ?? ''),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('supportMessageField'),
              controller: _messageController,
              maxLines: 5,
              enabled: !isSubmitting,
              onChanged: notifier.updateMessage,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Describe the issue you need help with.',
                errorText: state.fieldErrors['message'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('supportContactNameField'),
              controller: _nameController,
              enabled: !isSubmitting,
              onChanged: notifier.updateContactName,
              decoration: InputDecoration(
                labelText: 'Your name',
                errorText: state.fieldErrors['contactName'],
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SupportContactMethod>(
              key: const Key('supportContactMethodField'),
              initialValue: draft.contactMethod,
              decoration: const InputDecoration(
                labelText: 'Preferred contact method',
              ),
              items: const [
                DropdownMenuItem(
                  value: SupportContactMethod.email,
                  child: Text('Email'),
                ),
                DropdownMenuItem(
                  value: SupportContactMethod.phone,
                  child: Text('Phone'),
                ),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        notifier.updateContactMethod(value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            if (draft.contactMethod == SupportContactMethod.email)
              TextField(
                key: const Key('supportEmailField'),
                controller: _emailController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.emailAddress,
                onChanged: notifier.updateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: state.fieldErrors['email'],
                ),
              )
            else
              TextField(
                key: const Key('supportPhoneField'),
                controller: _phoneController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.phone,
                onChanged: notifier.updatePhone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  errorText: state.fieldErrors['phone'],
                ),
              ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const Key('supportConsentField'),
              contentPadding: EdgeInsets.zero,
              value: draft.consentAccepted,
              onChanged: isSubmitting
                  ? null
                  : (value) => notifier.updateConsentAccepted(value ?? false),
              title: const Text(
                'I consent to storing this support request for assistance and audit history.',
              ),
              subtitle: state.fieldErrors['consent'] == null
                  ? null
                  : Text(
                      state.fieldErrors['consent']!,
                      style: const TextStyle(color: Colors.red),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('supportSubmitButton'),
              onPressed: isSubmitting ? null : notifier.submit,
              child: Text(isSubmitting ? 'Submitting...' : 'Submit Ticket'),
            ),
            if (state.status ==
                ContactSupportSubmissionStatus.retryableError) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('supportRetryButton'),
                onPressed: notifier.retry,
                child: const Text('Retry'),
              ),
            ],
            if ((state.message ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _StatusCard(
                message: state.message!,
                isSuccess:
                    state.status == ContactSupportSubmissionStatus.success,
              ),
            ],
            if ((state.ticketRef ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Ticket Reference'),
                  subtitle: Text(state.ticketRef!),
                  trailing: const Icon(Icons.confirmation_number_outlined),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _syncControllers(ContactSupportDraft draft) {
    if (_messageController.text != draft.message) {
      _messageController.text = draft.message;
    }
    if (_nameController.text != draft.contactName) {
      _nameController.text = draft.contactName;
    }
    if (_emailController.text != draft.email) {
      _emailController.text = draft.email;
    }
    if (_phoneController.text != draft.phone) {
      _phoneController.text = draft.phone;
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, required this.isSuccess});

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final background = isSuccess
        ? const Color(0xFFECFDF3)
        : const Color(0xFFFEF3F2);
    final border = isSuccess
        ? const Color(0xFFABEFC6)
        : const Color(0xFFFECACA);
    final textColor = isSuccess
        ? const Color(0xFF027A48)
        : const Color(0xFFB42318);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
