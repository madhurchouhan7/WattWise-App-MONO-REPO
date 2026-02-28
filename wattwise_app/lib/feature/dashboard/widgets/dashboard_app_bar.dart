import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top app-bar row shown on the DashboardScreen.
///
/// Left  side: greeting text + bold user display name.
/// Right side: notification bell button.
class DashboardAppBar extends StatelessWidget {
  final String displayName;
  final VoidCallback? onNotificationTap;

  const DashboardAppBar({
    super.key,
    required this.displayName,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Greeting ──────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome back,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ── Notification bell ─────────────────────────────────
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
