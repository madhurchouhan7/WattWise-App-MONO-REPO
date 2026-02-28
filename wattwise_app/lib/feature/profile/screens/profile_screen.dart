import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/core/colors.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';
import 'package:wattwise_app/feature/profile/widgets/logout_button.dart';
import 'package:wattwise_app/feature/profile/widgets/profile_header.dart';
import 'package:wattwise_app/feature/profile/widgets/profile_menu_section.dart';
import 'package:wattwise_app/feature/profile/widgets/profile_stats_card.dart';
import 'package:wattwise_app/feature/profile/screens/manage_appliances_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const ProfileHeader().animate().fade().scale(
                begin: const Offset(0.9, 0.9),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 32),

              const ProfileStatsCard()
                  .animate()
                  .fade(delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              ProfileMenuSection(
                title: "ACCOUNT",
                items: [
                  MenuItemData(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profile",
                    onTap: () {},
                  ),
                  MenuItemData(
                    icon: Icons.kitchen_rounded,
                    title: "Manage Appliances",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageAppliancesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              ProfileMenuSection(
                title: "FEATURES",
                items: [
                  MenuItemData(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {},
                  ),
                  MenuItemData(
                    icon: Icons.solar_power_outlined,
                    title: "Solar Calculator",
                    onTap: () {},
                  ),
                ],
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              ProfileMenuSection(
                title: "HELP & INFO",
                items: [
                  MenuItemData(
                    icon: Icons.receipt_long_outlined,
                    title: "How to read bill",
                    onTap: () {},
                  ),
                  MenuItemData(
                    icon: Icons.help_outline_rounded,
                    title: "FAQs",
                    onTap: () {},
                  ),
                  MenuItemData(
                    icon: Icons.support_agent_rounded,
                    title: "Contact Support",
                    onTap: () {},
                  ),
                ],
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              ProfileMenuSection(
                title:
                    null, // Legal has no title over it according to the design
                items: [
                  MenuItemData(
                    icon: Icons.gavel_rounded,
                    title: "Legal",
                    onTap: () {},
                  ),
                ],
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              LogoutButton(
                onPressed: () => _showLogoutDialog(context, ref),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              Text(
                "Version 2.4.0",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withAlpha(150),
                ),
              ).animate().fade(delay: 700.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your WattWise account?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      // AppRouter is watching authStateProvider — it will automatically
      // redirect to WelcomeScreen once the stream emits null.
    }
  }
}
