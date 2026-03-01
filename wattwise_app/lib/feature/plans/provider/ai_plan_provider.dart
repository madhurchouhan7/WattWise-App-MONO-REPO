import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/plans/model/efficiency_plan_model.dart';
import 'package:wattwise_app/feature/plans/repository/ai_plan_repository.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/provider/on_boarding_page_5_notifier.dart';
import 'package:wattwise_app/feature/plans/provider/plan_preferences_provider.dart';

class AiPlanNotifier extends AutoDisposeAsyncNotifier<EfficiencyPlanModel?> {
  @override
  FutureOr<EfficiencyPlanModel?> build() {
    // Return null initially so we show the preference screen flow first.
    return null;
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

      return await repository.generatePlan(
        userGoalParams: userGoalParams,
        appliances: appliances,
        applianceStates: applianceStates,
        billInfo: billInfo,
      );
    });
  }
}

final aiPlanProvider =
    AsyncNotifierProvider.autoDispose<AiPlanNotifier, EfficiencyPlanModel?>(
      AiPlanNotifier.new,
    );
