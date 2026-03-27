import 'package:flutter_test/flutter_test.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';
import 'package:wattwise_app/feature/solar/repository/solar_repository.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';

void main() {
  test('required inputs validate before compute call', () async {
    final repository = _SpySolarRepository();
    final controller = SolarController(repository: repository);

    final ok = await controller.calculate();

    expect(ok, isFalse);
    expect(controller.state.status, SolarStatus.validationError);
    expect(
      controller.state.fieldErrors['monthlyUnits'],
      'Monthly units are required.',
    );
    expect(controller.state.fieldErrors['roofArea'], 'Roof area is required.');
    expect(controller.state.fieldErrors['state'], 'State is required.');
    expect(controller.state.fieldErrors['discom'], 'DISCOM is required.');
    expect(repository.calls, 0);
  });
}

class _SpySolarRepository implements ISolarRepository {
  int calls = 0;

  @override
  Future<SolarEstimateResult> estimate(SolarEstimateRequest request) async {
    calls += 1;
    return const SolarEstimateResult(
      recommendedSystemSizeKw: 3,
      estimatedMonthlyGenerationKwh: SolarRangeValue(
        low: 100,
        base: 120,
        high: 140,
      ),
      estimatedMonthlySavingsInr: SolarRangeValue(
        low: 800,
        base: 950,
        high: 1100,
      ),
      assumptions: <String, dynamic>{},
      limitations: <String>[],
      confidenceLabel: 'MEDIUM',
      disclaimer: 'test',
    );
  }
}
