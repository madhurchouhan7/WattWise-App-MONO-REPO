import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';
import 'package:wattwise_app/feature/solar/repository/solar_repository.dart';

void main() {
  test(
    'input edits trigger deterministic recalculation and updated output',
    () async {
      final repository = _CountingSolarRepository();
      final controller = SolarController(repository: repository);

      controller
        ..updateMonthlyUnits('450')
        ..updateRoofArea('1000')
        ..updateStateName('Maharashtra')
        ..updateDiscom('MSEDCL');

      final first = await controller.calculate();
      expect(first, isTrue);
      expect(controller.state.result?.estimatedMonthlyGenerationKwh.base, 490);
      expect(repository.calls, 1);

      controller.updateMonthlyUnits('500');
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(repository.calls, 2);
      expect(controller.state.result?.estimatedMonthlyGenerationKwh.base, 520);
    },
  );
}

class _CountingSolarRepository implements ISolarRepository {
  int calls = 0;

  @override
  Future<SolarEstimateResult> estimate(SolarEstimateRequest request) async {
    calls += 1;
    final monthlyUnits = request.monthlyUnits;

    if (monthlyUnits >= 500) {
      return const SolarEstimateResult(
        recommendedSystemSizeKw: 4.8,
        estimatedMonthlyGenerationKwh: SolarRangeValue(
          low: 470,
          base: 520,
          high: 580,
        ),
        estimatedMonthlySavingsInr: SolarRangeValue(
          low: 3500,
          base: 3900,
          high: 4350,
        ),
        assumptions: <String, dynamic>{
          'state': 'Maharashtra',
          'discom': 'MSEDCL',
          'tariffRateInrPerKwh': 8.1,
        },
        limitations: <String>['Informational estimate only.'],
        confidenceLabel: 'MEDIUM',
        disclaimer: 'Range, not guarantee.',
      );
    }

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
      limitations: <String>['Informational estimate only.'],
      confidenceLabel: 'MEDIUM',
      disclaimer: 'Range, not guarantee.',
    );
  }
}
