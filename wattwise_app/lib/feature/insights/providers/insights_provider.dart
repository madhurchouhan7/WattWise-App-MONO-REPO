import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';

// Dynamically sets current month context
final selectedMonthProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[now.month - 1]} ${now.year}';
});

// Provides dynamic Efficiency Score from the AI Plan schema
final efficiencyScoreProvider = Provider<int>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final activePlan = userAsync.valueOrNull?.activePlan;

  if (activePlan != null && activePlan['efficiencyScore'] != null) {
    return (activePlan['efficiencyScore'] as num).toInt();
  }
  return 82; // Fallback
});

// Dynamic appliance breakdown based on what the AI prioritized
final applianceBreakdownProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final activePlan = userAsync.valueOrNull?.activePlan;

  if (activePlan != null && activePlan['keyActions'] != null) {
    final actions = activePlan['keyActions'] as List<dynamic>;
    if (actions.isNotEmpty) {
      return [
        {
          'name': actions.isNotEmpty
              ? actions[0]['appliance']
                    ?.toString()
                    .split(" ")[0]
                    .replaceAll(RegExp(r'[^a-zA-Z]'), '')
              : 'AC',
          'percentage': 45,
          'colorHex': 0xFF2563EB,
        },
        {
          'name': actions.length > 1
              ? actions[1]['appliance']
                    ?.toString()
                    .split(" ")[0]
                    .replaceAll(RegExp(r'[^a-zA-Z]'), '')
              : 'Fridge',
          'percentage': 30,
          'colorHex': 0xFF93C5FD,
        },
        {'name': 'Other', 'percentage': 25, 'colorHex': 0xFFE2E8F0},
      ];
    }
  }

  return [
    {'name': 'AC', 'percentage': 40, 'colorHex': 0xFF2563EB},
    {'name': 'Fridge', 'percentage': 20, 'colorHex': 0xFF93C5FD},
    {'name': 'Other', 'percentage': 40, 'colorHex': 0xFFE2E8F0},
  ];
});

// Dynamic daily intensity (heatmap data)
// 0: low/none, 1: light, 2: medium, 3: high (HI)
final dailyIntensityProvider = Provider<List<int>>((ref) {
  final score = ref.watch(efficiencyScoreProvider);

  if (score > 85) {
    // Highly efficient pattern
    return [0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0];
  } else if (score < 60) {
    // Inefficient pattern
    return [2, 3, 2, 3, 3, 2, 1, 3, 3, 2, 2, 3, 2, 2];
  }

  // Moderate
  return [0, 1, 1, 2, 3, 1, 0, 0, 0, 2, 1, 1, 3, 1];
});
