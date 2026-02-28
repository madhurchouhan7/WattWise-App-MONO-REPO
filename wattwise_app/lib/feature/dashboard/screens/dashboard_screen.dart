import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';
import 'package:wattwise_app/feature/dashboard/providers/dashboard_provider.dart';
import 'package:wattwise_app/feature/dashboard/widgets/dashboard_app_bar.dart';
import 'package:wattwise_app/feature/dashboard/widgets/no_bills_empty_state.dart';
import 'package:wattwise_app/feature/dashboard/widgets/quick_check_in_bottom_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── State ──────────────────────────────────────────────────────────
    final userAsync = ref.watch(authStateProvider);
    final hasBills = ref.watch(hasBillsProvider);

    final displayName =
        userAsync.valueOrNull?.displayName?.split(' ').first ??
        userAsync.valueOrNull?.email?.split('@').first ??
        'there';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SafeArea(
          child: hasBills
              ? _DataView(displayName: displayName)
              : _EmptyView(displayName: displayName),
        ),
      ),
    );
  }
}

// ─── Empty State (no bills added) ─────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final String displayName;
  const _EmptyView({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── App bar ──────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: width * 0.04,
          ),
          child: DashboardAppBar(
            displayName: displayName,
            onNotificationTap: () {
              // TODO: navigate to notifications
            },
          ),
        ),

        // ── Empty state centred in remaining space ────────────
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: width * 0.04),
              child: NoBillsEmptyState(
                onAddBill: () {
                  // TODO: navigate to add bill screen
                  // Navigator.push(context, MaterialPageRoute(...))
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Data View (bills exist) ──────────────────────────────────────────────────
class _DataView extends ConsumerWidget {
  final String displayName;
  const _DataView({required this.displayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardAppBar(displayName: displayName),
            const SizedBox(height: 32),
            _buildStatCards(),
            const SizedBox(height: 28),
            _buildSectionTitle('Active Plan', showIndicator: true),
            const SizedBox(height: 16),
            _buildActivePlanCard(context),
            const SizedBox(height: 28),
            _buildSectionTitle('Action Items'),
            const SizedBox(height: 16),
            _buildActionItems(),
            const SizedBox(height: 28),
            _buildSectionTitleWithAction('Recent Activity', 'View All'),
            const SizedBox(height: 16),
            _buildRecentActivity(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconWidget: const Icon(
              Icons.receipt_long,
              color: Color(0xFF1E60F2),
              size: 20,
            ),
            iconBg: const Color(0xFFEFF6FF),
            badge: _TrendBadge(value: '4%', isUp: true),
            label: 'Est. Current Bill',
            value: '₹5,240',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            iconWidget: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF10B981),
              size: 20,
            ),
            iconBg: const Color(0xFFECFDF5),
            label: 'Last Paid',
            value: '₹4,890',
            subLabel: 'Paid on Feb 1st',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool showIndicator = false}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        if (showIndicator) ...[
          const SizedBox(width: 8),
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitleWithAction(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        Text(
          action,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF1E60F2),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60F2), Color(0xFF144CC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E60F2).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AC Cooling Plan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tier 2 Usage',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              Text(
                '650 / 800 kWh',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (_, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3996),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: constraints.maxWidth * 0.81,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => showQuickCheckInBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E60F2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quick Check-in',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItems() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFFEDD5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFFEA580C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Heat Advisory',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expect higher usage today due to temperatures reaching 40°C.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Log New Meter Reading',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'February Bill',
        'subtitle': 'Due Feb 28',
        'amount': '₹4,890',
        'status': 'Paid',
        'isPaid': true,
      },
      {
        'title': 'January Bill',
        'subtitle': 'Due Jan 31',
        'amount': '₹4,310',
        'status': 'Paid',
        'isPaid': true,
      },
      {
        'title': 'Service Fee',
        'subtitle': 'Jan 15',
        'amount': '₹180',
        'status': 'Posted',
        'isPaid': false,
        'isGrey': true,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isGrey = (item['isGrey'] as bool?) ?? false;
          final isPaid = (item['isPaid'] as bool?) ?? false;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGrey
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        isGrey
                            ? Icons.build_outlined
                            : Icons.description_outlined,
                        color: isGrey
                            ? const Color(0xFF64748B)
                            : const Color(0xFF1E60F2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['amount'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isPaid
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < activities.length - 1)
                const Divider(
                  height: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBg;
  final Widget? badge;
  final String label;
  final String value;
  final String? subLabel;

  const _StatCard({
    required this.iconWidget,
    required this.iconBg,
    required this.label,
    required this.value,
    this.badge,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconWidget,
              ),
              if (badge != null) badge!,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final String value;
  final bool isUp;

  const _TrendBadge({required this.value, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUp ? const Color(0xFFFEF2F2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: isUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
