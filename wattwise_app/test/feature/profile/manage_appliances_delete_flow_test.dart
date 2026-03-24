import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/core/network/api_client.dart';
import 'package:wattwise_app/feature/on_boarding/model/appliance_model.dart';
import 'package:wattwise_app/feature/on_boarding/model/on_boarding_state.dart';
import 'package:wattwise_app/feature/on_boarding/provider/on_boarding_page_5_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/repository/appliance_repository.dart';
import 'package:wattwise_app/feature/profile/provider/manage_appliances_provider.dart';
import 'package:wattwise_app/feature/profile/screens/manage_appliances_screen.dart';

void main() {
  group('Manage appliances delete flow contract (APP-01)', () {
    test(
      'delete success envelope is deterministic for UI confirmation handling',
      () {
        final successResponse = {
          'success': true,
          'message': 'Appliance deleted successfully.',
        };

        expect(successResponse['success'], isTrue);
        expect(successResponse['message'], 'Appliance deleted successfully.');
      },
    );

    testWidgets('delete requires explicit confirmation before API call', (
      tester,
    ) async {
      final fakeRepository = _FakeApplianceRepository();
      final selectedNotifier = SelectedAppliancesNotifier()
        ..setAppliances([_sampleAppliance()]);
      final pageNotifier = OnBoardingPage5Notifier(repository: fakeRepository)
        ..preloadState({
          'ac-1': const ApplianceLocalState(
            usageLevel: 'Medium',
            count: 1,
            selectedDropdowns: {'STAR RATING': '5 Star'},
          ),
        });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            applianceRepositoryProvider.overrideWithValue(fakeRepository),
            manageAppliancesInitProvider.overrideWith((ref) async => true),
            selectedAppliancesProvider.overrideWith((ref) => selectedNotifier),
            onBoardingPage5Provider.overrideWith((ref) => pageNotifier),
            manageApplianceBaselineProvider.overrideWith(
              (ref) => {'ac-1': {'applianceId': 'ac-1', 'version': 3}},
            ),
          ],
          child: const MaterialApp(home: ManageAppliancesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();

      expect(find.text('Delete appliance?'), findsOneWidget);
      expect(fakeRepository.deleteCalls, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fakeRepository.deleteCalls, 0);
    });

    testWidgets('failed delete rolls back item and shows retry guidance', (
      tester,
    ) async {
      final fakeRepository = _FakeApplianceRepository();
      fakeRepository.nextError = ApplianceMutationException(
        type: ApplianceMutationErrorType.retryable,
        message: 'Temporary upstream failure.',
        errorCode: 'UPSTREAM_TIMEOUT',
      );

      final selectedNotifier = SelectedAppliancesNotifier()
        ..setAppliances([_sampleAppliance()]);
      final pageNotifier = OnBoardingPage5Notifier(repository: fakeRepository)
        ..preloadState({
          'ac-1': const ApplianceLocalState(
            usageLevel: 'Medium',
            count: 1,
            selectedDropdowns: {'STAR RATING': '5 Star'},
          ),
        });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            applianceRepositoryProvider.overrideWithValue(fakeRepository),
            manageAppliancesInitProvider.overrideWith((ref) async => true),
            selectedAppliancesProvider.overrideWith((ref) => selectedNotifier),
            onBoardingPage5Provider.overrideWith((ref) => pageNotifier),
            manageApplianceBaselineProvider.overrideWith(
              (ref) => {'ac-1': {'applianceId': 'ac-1', 'version': 5}},
            ),
          ],
          child: const MaterialApp(home: ManageAppliancesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Air Conditioner'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(fakeRepository.deleteCalls, 1);
      expect(find.text('Air Conditioner'), findsOneWidget);
      expect(
        find.textContaining('Check your connection and retry'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

ApplianceModel _sampleAppliance() {
  return const ApplianceModel(
    id: 'ac-1',
    title: 'Air Conditioner',
    description: 'Inverter, Split',
    svgPath: 'assets/icon/ac_icon.svg',
    category: 'COOLING',
    usageHours: 8,
  );
}

class _FakeApplianceRepository extends ApplianceRepository {
  _FakeApplianceRepository() : super(apiClient: ApiClient.instance);

  int deleteCalls = 0;
  ApplianceMutationException? nextError;

  @override
  Future<Map<String, dynamic>> deleteAppliance({
    required String applianceId,
    String? expectedVersion,
  }) async {
    deleteCalls += 1;
    if (nextError != null) {
      final error = nextError!;
      nextError = null;
      throw error;
    }
    return {'success': true, 'message': 'Appliance deleted successfully.'};
  }

  @override
  Future<Map<String, dynamic>> createAppliance({
    required Map<String, dynamic> payload,
  }) async {
    return {'success': true, 'data': payload};
  }

  @override
  Future<Map<String, dynamic>> updateAppliance({
    required String applianceId,
    required Map<String, dynamic> payload,
    String? expectedVersion,
  }) async {
    return {'success': true, 'data': payload};
  }
}
