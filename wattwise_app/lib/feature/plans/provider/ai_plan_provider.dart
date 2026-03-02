import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wattwise_app/feature/plans/model/efficiency_plan_model.dart';
import 'package:wattwise_app/feature/plans/repository/ai_plan_repository.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/provider/on_boarding_page_5_notifier.dart';
import 'package:wattwise_app/feature/plans/provider/plan_preferences_provider.dart';

const String _kCachedPlanKey = 'cached_ai_efficiency_plan';

class AiPlanNotifier extends AsyncNotifier<EfficiencyPlanModel?> {
  @override
  FutureOr<EfficiencyPlanModel?> build() async {
    // Attempt to hydrate from disk cache when the app starts.
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_kCachedPlanKey);

    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        return EfficiencyPlanModel.fromJson(decoded);
      } catch (e) {
        // Fallback gracefully on corrupted local cache
      }
    }

    return null; // Go to preference flow
  }

  Future<void> generatePlan() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(aiPlanRepositoryProvider);
      final appliances = ref.read(selectedAppliancesProvider);
      final applianceStates = ref.read(onBoardingPage5Provider).localStates;
      final preferences = ref.read(planPreferencesProvider);

      final userGoalParams = {
        "goal": preferences.mainGoals.isNotEmpty
            ? preferences.mainGoals.join(',')
            : "reduce_bill",
        "focusArea": preferences.focusArea,
        "location": "India",
      };

      final billInfo = {
        "month": "January 2026",
        "unitsConsumed": 450,
        "totalAmount": 3200,
        "pricePerUnit": 7.11,
      };

      final generatedPlan = await repository.generatePlan(
        userGoalParams: userGoalParams,
        appliances: appliances,
        applianceStates: applianceStates,
        billInfo: billInfo,
      );

      // Save it locally!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kCachedPlanKey,
        jsonEncode(generatedPlan.toJson()),
      );

      return generatedPlan;
    });
  }

  Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachedPlanKey);
    state = const AsyncData(null);
  }
}

final aiPlanProvider =
    AsyncNotifierProvider<AiPlanNotifier, EfficiencyPlanModel?>(
      AiPlanNotifier.new,
    );
