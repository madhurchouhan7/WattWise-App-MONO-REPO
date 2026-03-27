import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';
import 'package:wattwise_app/feature/solar/repository/solar_repository.dart';
import 'package:wattwise_app/feature/solar/screens/solar_calculator_screen.dart';

void main() {
  testWidgets(
    'successful compute renders ranges, assumptions, confidence, and disclaimer',
    (tester) async {
      final repository = _FakeSolarRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [solarRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: SolarCalculatorScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('solarMonthlyUnitsField')),
        '450',
      );
      await tester.enterText(
        find.byKey(const Key('solarRoofAreaField')),
        '1000',
      );
      await tester.enterText(
        find.byKey(const Key('solarStateField')),
        'Maharashtra',
      );
      await tester.enterText(
        find.byKey(const Key('solarDiscomField')),
        'MSEDCL',
      );

      await tester.ensureVisible(find.byKey(const Key('solarCalculateButton')));
      await tester.tap(find.byKey(const Key('solarCalculateButton')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Low:'), findsNWidgets(2));
      expect(find.textContaining('Base:'), findsNWidgets(2));
      expect(find.textContaining('High:'), findsNWidgets(2));
      expect(find.text('Confidence Label'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('Assumptions'), findsOneWidget);
      expect(find.byKey(const Key('solarDisclaimerText')), findsOneWidget);
    },
  );
}

class _FakeSolarRepository implements ISolarRepository {
  @override
  Future<SolarEstimateResult> estimate(SolarEstimateRequest request) async {
    return const SolarEstimateResult(
      recommendedSystemSizeKw: 4.2,
      estimatedMonthlyGenerationKwh: SolarRangeValue(
        low: 430,
        base: 490,
        high: 550,
      ),
      estimatedMonthlySavingsInr: SolarRangeValue(
        low: 3200,
        base: 3600,
        high: 4050,
      ),
      assumptions: <String, dynamic>{
        'state': 'Maharashtra',
        'discom': 'MSEDCL',
        'tariffRateInrPerKwh': 8.1,
      },
      limitations: <String>[
        'Estimate excludes on-site survey.',
        'Estimate is informational.',
      ],
      confidenceLabel: 'MEDIUM',
      disclaimer: 'This is an informational estimate range.',
    );
  }
}
