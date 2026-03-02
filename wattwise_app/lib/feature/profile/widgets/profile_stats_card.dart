import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/core/colors.dart';
import 'package:wattwise_app/feature/bill/providers/fetch_bill_provider.dart';

class ProfileStatsCard extends ConsumerWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedBill = ref.watch(savedBillProvider);
    final hasBills = savedBill != null;

    final String billsCount = hasBills ? "1" : "0";
    final String savings = hasBills
        ? "₹${(savedBill['amountExact'] ?? 0) * 0.1 > 100 ? 120 : 0}"
        : "₹0";

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Light grey/blue background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlue.withAlpha(25), // 10% opacity blue
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(billsCount, "Bills"),
              _buildDivider(),
              _buildStatColumn(savings, "Saved"),
              _buildDivider(),
              _buildStatColumn(hasBills ? "1" : "0", "Streak"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }
}
