import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';
import 'package:wattwise_app/feature/solar/repository/solar_repository.dart';
import 'package:wattwise_app/feature/solar/screens/solar_calculator_screen.dart';

void main() {
  testWidgets('disclaimer text is visible with every computed result', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          solarRepositoryProvider.overrideWithValue(
            _DisclaimerSolarRepository(),
          ),
        ],
        child: const MaterialApp(home: SolarCalculatorScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('solarMonthlyUnitsField')),
      '420',
    );
    await tester.enterText(find.byKey(const Key('solarRoofAreaField')), '900');
    await tester.enterText(
      find.byKey(const Key('solarStateField')),
      'Karnataka',
    );
    await tester.enterText(find.byKey(const Key('solarDiscomField')), 'BESCOM');

    await tester.ensureVisible(find.byKey(const Key('solarCalculateButton')));
    await tester.tap(find.byKey(const Key('solarCalculateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('solarDisclaimerText')), findsOneWidget);
    expect(find.textContaining('informational estimate range'), findsOneWidget);
  });
}

class _DisclaimerSolarRepository implements ISolarRepository {
  @override
  Future<SolarEstimateResult> estimate(SolarEstimateRequest request) async {
    return const SolarEstimateResult(
      recommendedSystemSizeKw: 3.6,
      estimatedMonthlyGenerationKwh: SolarRangeValue(
        low: 330,
        base: 380,
        high: 430,
      ),
      estimatedMonthlySavingsInr: SolarRangeValue(
        low: 2500,
        base: 2900,
        high: 3300,
      ),
      assumptions: <String, dynamic>{
        'state': 'Karnataka',
        'discom': 'BESCOM',
        'tariffRateInrPerKwh': 7.8,
      },
      limitations: <String>['Estimate excludes onsite survey.'],
      confidenceLabel: 'MEDIUM',
      disclaimer:
          'This solar output is an informational estimate range and should not be treated as a guaranteed quote.',
    );
  }
}
