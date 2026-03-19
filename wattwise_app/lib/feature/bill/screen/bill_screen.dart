import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wattwise_app/core/colors.dart';
import 'package:wattwise_app/feature/bill/screen/add_bill_screen.dart';
import 'package:wattwise_app/feature/bill/widgets/bill_header.dart';
import 'package:wattwise_app/feature/bill/widgets/current_cycle_card.dart';
import 'package:wattwise_app/feature/bill/widgets/bill_history_tile.dart';
import '../providers/fetch_bill_provider.dart';

class BillScreen extends ConsumerWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedBill = ref.watch(savedBillProvider);
    String amountStr = '0';
    if (savedBill != null && savedBill['amountExact'] != null) {
      final rawAmount = savedBill['amountExact'];
      if (rawAmount is int) {
        amountStr = rawAmount.toString();
      } else if (rawAmount is double) {
        amountStr = rawAmount.toStringAsFixed(2);
      } else {
        amountStr = rawAmount.toString();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BillHeader().animate().fade().slideY(begin: -0.2, end: 0),

              const SizedBox(height: 32),

              const CurrentCycleCard()
                  .animate()
                  .fade(delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              if (savedBill != null && savedBill['imageBase64'] != null && savedBill['imageBase64'].toString().isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  "Scanned Bill",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fade(delay: 150.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      base64Decode(savedBill['imageBase64']),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ).animate().fade(delay: 150.ms).slideY(begin: 0.1, end: 0),
              ],

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "History",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon( 
                          Icons.delete_outline,
                          color: savedBill != null ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        tooltip: "Remove Active Bill",
                        onPressed: savedBill != null
                            ? () {
                                ref
                                    .read(savedBillProvider.notifier)
                                    .clearBill();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Dummy bill cleared'),
                                  ),
                                );
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Last 6 months",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              if (savedBill != null)
                BillHistoryTile(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.ecoGreen,
                  date: savedBill['billerId'] ?? "Default",
                  usage:
                      savedBill['units'].toString() == '0' ||
                          savedBill['units'] == null
                      ? '450'
                      : savedBill['units'].toString(),
                  rate: "-",
                  amount: "₹$amountStr",
                  trend: "New",
                  isTrendingUp: false,
                  isTrendNeutral: true,
                ).animate().fade(delay: 250.ms).slideY(begin: 0.1, end: 0),

              // ── Mock bill history (commented out until real data is available) ──
              // const BillHistoryTile(
              //   icon: Icons.wb_sunny_outlined,
              //   iconColor: AppColors.solarAmber,
              //   date: "July 2023",
              //   usage: "520",
              //   rate: "16.7",
              //   amount: "\$98.20",
              //   trend: "5%",
              //   isTrendingUp: false,
              //   isTrendNeutral: false,
              // ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),

              // const BillHistoryTile(
              //   icon: Icons.water_drop_outlined,
              //   iconColor: AppColors.primaryBlue,
              //   date: "June 2023",
              //   usage: "480",
              //   rate: "16.0",
              //   amount: "\$92.15",
              //   trend: "0%",
              //   isTrendingUp: false,
              //   isTrendNeutral: true,
              // ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),

              // const BillHistoryTile(
              //   icon: Icons.cloud_outlined,
              //   iconColor: Colors.purpleAccent,
              //   date: "May 2023",
              //   usage: "455",
              //   rate: "14.6",
              //   amount: "\$88.40",
              //   trend: "2%",
              //   isTrendingUp: true,
              //   isTrendNeutral: false,
              // ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),

              // const BillHistoryTile(
              //   icon: Icons.cloud_queue_rounded,
              //   iconColor: Colors.grey,
              //   date: "April 2023",
              //   usage: "410",
              //   rate: "13.6",
              //   amount: "\$84.10",
              //   trend: "1%",
              //   isTrendingUp: true,
              //   isTrendNeutral: false,
              // ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(
                height: 80,
              ), // Extra space for FAB and bottom navbar
            ],
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: AddBillScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1E60F2),
            elevation: 8,
            //shadowColor: const Color(0xFF1E60F2).withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "Add Bill",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ).animate().fade().scale(
            delay: 600.ms,
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
