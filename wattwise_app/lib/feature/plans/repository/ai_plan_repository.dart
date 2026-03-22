import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/plans/model/efficiency_plan_model.dart';
import 'package:wattwise_app/feature/on_boarding/model/appliance_model.dart';
import 'package:wattwise_app/feature/on_boarding/model/on_boarding_state.dart';
import 'package:wattwise_app/core/network/api_client.dart';

final aiPlanRepositoryProvider = Provider(
  (ref) => AiPlanRepository(ApiClient.instance),
);

class AiPlanRepository {
  final ApiClient _client;

  AiPlanRepository(this._client);

  Future<EfficiencyPlanModel> generatePlan({
    required Map<String, dynamic> userGoalParams,
    required List<ApplianceModel> appliances,
    required Map<String, ApplianceLocalState> applianceStates,
    required Map<String, dynamic> billInfo,
  }) async {
    try {
      final List<Map<String, dynamic>> applianceList = appliances.map((app) {
        final state = applianceStates[app.id];
        return {
          "name": app.title,
          "count": state?.count ?? 1,
          "usageLevel": state?.usageLevel ?? "Medium",
          "wattage": _extractWattage(state?.selectedDropdowns),
          "starRating": _extractStar(state?.selectedDropdowns),
        };
      }).toList();

      final payload = {
        "user": userGoalParams,
        "appliances": applianceList,
        "bill": billInfo,
      };

      final response = await _client.post(
        '/ai/generate-plan',
        data: payload,
        // Gemini API can take 25-35s — override only for this call
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return EfficiencyPlanModel.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to generate plan");
      }
    } catch (e) {
      throw Exception("Error generating AI Plan: $e");
    }
  }

  String _extractWattage(Map<String, String>? dropdowns) {
    if (dropdowns == null) return "unknown";
    return dropdowns.values.firstWhere(
      (v) => v.contains("W") || v.contains("Ton") || v.contains("Liters"),
      orElse: () => "unknown",
    );
  }

  String _extractStar(Map<String, String>? dropdowns) {
    if (dropdowns == null) return "unknown";
    return dropdowns.values.firstWhere(
      (v) => v.contains("Star"),
      orElse: () => "unknown",
    );
  }
}
