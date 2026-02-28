import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/on_boarding/repository/appliance_repository.dart';
import 'package:wattwise_app/feature/on_boarding/model/appliance_model.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/provider/on_boarding_page_5_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/model/on_boarding_state.dart';

final manageAppliancesInitProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final repository = ref.read(applianceRepositoryProvider);
  final appliancesData = await repository.getAppliances();

  final selectedNotifier = ref.read(selectedAppliancesProvider.notifier);
  final page5Notifier = ref.read(onBoardingPage5Provider.notifier);

  // Clear previous state just in case
  selectedNotifier.clearAll();

  if (appliancesData.isEmpty) {
    return true; // No data, start fresh
  }

  List<ApplianceModel> prefilledAppliances = [];
  Map<String, ApplianceLocalState> prefilledStates = {};

  for (var data in appliancesData) {
    final applianceId = data['applianceId'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final category = data['category'] as String? ?? '';
    final svgPath = data['svgPath'] as String? ?? '';
    final usageHours = (data['usageHours'] as num?)?.toDouble() ?? 2.0;

    final model = ApplianceModel(
      id: applianceId,
      title: title,
      category: category,
      usageHours: usageHours,
      svgPath: svgPath,
      description: '',
    );

    prefilledAppliances.add(model);

    // Parse dropdowns carefully
    final dropdownMap =
        data['selectedDropdowns'] as Map<String, dynamic>? ?? {};
    final Map<String, String> mappedDropdowns = {};
    dropdownMap.forEach((k, v) {
      mappedDropdowns[k] = v.toString();
    });

    prefilledStates[applianceId] = ApplianceLocalState(
      usageLevel: data['usageLevel'] as String? ?? 'Medium',
      count: data['count'] as int? ?? 1,
      selectedDropdowns: mappedDropdowns,
    );
  }

  // Pre-load logic into the global providers
  selectedNotifier.setAppliances(prefilledAppliances);
  page5Notifier.preloadState(prefilledStates);

  return true;
});
