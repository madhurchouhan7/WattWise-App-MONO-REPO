import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/solar/models/solar_models.dart';
import 'package:wattwise_app/feature/solar/provider/solar_provider.dart';

class SolarCalculatorScreen extends ConsumerStatefulWidget {
  const SolarCalculatorScreen({super.key});

  @override
  ConsumerState<SolarCalculatorScreen> createState() =>
      _SolarCalculatorScreenState();
}

class _SolarCalculatorScreenState extends ConsumerState<SolarCalculatorScreen> {
  final _monthlyUnitsController = TextEditingController();
  final _roofAreaController = TextEditingController();
  final _stateController = TextEditingController();
  final _discomController = TextEditingController();
  final _sanctionedLoadController = TextEditingController();

  @override
  void dispose() {
    _monthlyUnitsController.dispose();
    _roofAreaController.dispose();
    _stateController.dispose();
    _discomController.dispose();
    _sanctionedLoadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solarProvider);
    final notifier = ref.read(solarProvider.notifier);

    _syncControllers(state.draft);

    final result = state.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Solar Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('solarMonthlyUnitsField'),
              controller: _monthlyUnitsController,
              keyboardType: TextInputType.number,
              onChanged: notifier.updateMonthlyUnits,
              decoration: InputDecoration(
                labelText: 'Monthly units (kWh)',
                errorText: state.fieldErrors['monthlyUnits'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('solarRoofAreaField'),
              controller: _roofAreaController,
              keyboardType: TextInputType.number,
              onChanged: notifier.updateRoofArea,
              decoration: InputDecoration(
                labelText: 'Roof area (sq ft)',
                errorText: state.fieldErrors['roofArea'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('solarStateField'),
              controller: _stateController,
              onChanged: notifier.updateStateName,
              decoration: InputDecoration(
                labelText: 'State',
                errorText: state.fieldErrors['state'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('solarDiscomField'),
              controller: _discomController,
              onChanged: notifier.updateDiscom,
              decoration: InputDecoration(
                labelText: 'DISCOM',
                errorText: state.fieldErrors['discom'],
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('solarShadingField'),
              initialValue: state.draft.shadingLevel,
              decoration: const InputDecoration(labelText: 'Shading level'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) =>
                  notifier.updateShadingLevel(value ?? 'medium'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('solarSanctionedLoadField'),
              controller: _sanctionedLoadController,
              keyboardType: TextInputType.number,
              onChanged: notifier.updateSanctionedLoad,
              decoration: const InputDecoration(
                labelText: 'Sanctioned load (kW) - optional',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('solarCalculateButton'),
              onPressed: state.status == SolarStatus.loading
                  ? null
                  : notifier.calculate,
              child: Text(
                state.status == SolarStatus.loading
                    ? 'Calculating...'
                    : 'Calculate Estimate',
              ),
            ),
            if ((state.message ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(state.message!),
            ],
            if (result != null) ...[
              const SizedBox(height: 16),
              _RangeCard(
                title: 'Estimated monthly generation (kWh)',
                range: result.estimatedMonthlyGenerationKwh,
              ),
              const SizedBox(height: 12),
              _RangeCard(
                title: 'Estimated monthly savings (INR)',
                range: result.estimatedMonthlySavingsInr,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Recommended system size'),
                  subtitle: Text(
                    '${result.recommendedSystemSizeKw.toStringAsFixed(2)} kW',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Confidence Label'),
                  subtitle: Text(result.confidenceLabel),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assumptions'),
                      const SizedBox(height: 8),
                      Text('State: ${result.assumptions['state'] ?? ''}'),
                      Text('DISCOM: ${result.assumptions['discom'] ?? ''}'),
                      Text(
                        'Tariff: ${result.assumptions['tariffRateInrPerKwh'] ?? ''} INR/kWh',
                      ),
                      const SizedBox(height: 8),
                      const Text('Limitations'),
                      ...result.limitations.map((item) => Text('- $item')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Disclaimer: ${result.disclaimer}',
                    key: const Key('solarDisclaimerText'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _syncControllers(SolarDraft draft) {
    if (_monthlyUnitsController.text != draft.monthlyUnits) {
      _monthlyUnitsController.text = draft.monthlyUnits;
    }
    if (_roofAreaController.text != draft.roofArea) {
      _roofAreaController.text = draft.roofArea;
    }
    if (_stateController.text != draft.state) {
      _stateController.text = draft.state;
    }
    if (_discomController.text != draft.discom) {
      _discomController.text = draft.discom;
    }
    if (_sanctionedLoadController.text != draft.sanctionedLoadKw) {
      _sanctionedLoadController.text = draft.sanctionedLoadKw;
    }
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.title, required this.range});

  final String title;
  final SolarRangeValue range;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text('Low: ${range.low.toStringAsFixed(2)}'),
            Text('Base: ${range.base.toStringAsFixed(2)}'),
            Text('High: ${range.high.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
