import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/plans/provider/ai_plan_provider.dart';
import 'package:wattwise_app/feature/plans/screens/design_plan_screen.dart';
import 'package:wattwise_app/feature/plans/widgets/generated_plan_view.dart';
import 'package:wattwise_app/core/colors.dart';
import 'package:shimmer/shimmer.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  @override
  Widget build(BuildContext context) {
    final aiPlanState = ref.watch(aiPlanProvider);

    return aiPlanState.when(
      data: (plan) {
        if (plan == null) {
          // 1. If plan hasn't been generated yet, show the design flow
          return const DesignPlanScreen();
        }

        // 2. If plan is generated, show the GeneratedPlanView with its Scaffold
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'AI Efficiency Plan',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(aiPlanProvider.notifier).generatePlan();
                },
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              ),
            ],
          ),
          body: GeneratedPlanView(plan: plan),
        );
      },
      loading: () =>
          Scaffold(backgroundColor: Colors.white, body: _buildLoadingShimmer()),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to generate plan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(aiPlanProvider.notifier).generatePlan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            // Title skeleton
            Container(width: 200, height: 32, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 150, height: 32, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 300, height: 16, color: Colors.white),
            const SizedBox(height: 32),
            // Blue card skeleton
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 32),
            // Action highlights skeleton
            Container(width: 140, height: 16, color: Colors.white),
            const SizedBox(height: 24),
            // Action items
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 200,
                            height: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
