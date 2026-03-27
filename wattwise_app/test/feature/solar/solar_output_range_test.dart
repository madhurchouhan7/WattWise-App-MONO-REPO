import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';
import 'package:wattwise_app/feature/solar/repository/solar_repository.dart';
import 'package:wattwise_app/feature/solar/screens/solar_calculator_screen.dart';

void main() {
  testWidgets(
    'range output displays low/base/high values for generation and savings',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            solarRepositoryProvider.overrideWithValue(_RangeSolarRepository()),
          ],
          child: const MaterialApp(home: SolarCalculatorScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('solarMonthlyUnitsField')),
        '500',
      );
      await tester.enterText(
        find.byKey(const Key('solarRoofAreaField')),
        '1200',
      );
      await tester.enterText(find.byKey(const Key('solarStateField')), 'Delhi');
      await tester.enterText(find.byKey(const Key('solarDiscomField')), 'BSES');

      await tester.ensureVisible(find.byKey(const Key('solarCalculateButton')));
      await tester.tap(find.byKey(const Key('solarCalculateButton')));
      await tester.pumpAndSettle();

      expect(find.text('Low: 200.00'), findsOneWidget);
      expect(find.text('Base: 250.00'), findsOneWidget);
      expect(find.text('High: 300.00'), findsOneWidget);

      expect(find.text('Low: 1500.00'), findsOneWidget);
      expect(find.text('Base: 1900.00'), findsOneWidget);
      expect(find.text('High: 2300.00'), findsOneWidget);
    },
  );
}

class _RangeSolarRepository implements ISolarRepository {
  @override
  Future<SolarEstimateResult> estimate(SolarEstimateRequest request) async {
    return const SolarEstimateResult(
      recommendedSystemSizeKw: 5,
      estimatedMonthlyGenerationKwh: SolarRangeValue(
        low: 200,
        base: 250,
        high: 300,
      ),
      estimatedMonthlySavingsInr: SolarRangeValue(
        low: 1500,
        base: 1900,
        high: 2300,
      ),
      assumptions: <String, dynamic>{
        'state': 'Delhi',
        'discom': 'BSES',
        'tariffRateInrPerKwh': 8.5,
      },
      limitations: <String>['Informational estimate only.'],
      confidenceLabel: 'LOW',
      disclaimer: 'Always verify with onsite survey.',
    );
  }
}
