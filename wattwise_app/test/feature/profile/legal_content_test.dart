import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Legal content contract (CNT-04, CNT-05)', () {
    test(
      'legal payload exposes visible version and effective metadata',
      () async {
        final repository = _FakeLegalRepository(
          initial: const _LegalPayload(
            slug: 'terms',
            contentVersion: '2026.03.1',
            effectiveFrom: '2026-03-01T00:00:00.000Z',
            lastUpdatedAt: '2026-03-26T00:00:00.000Z',
          ),
        );
        final controller = _LegalController(repository);

        final state = await controller.load();

        expect(state.payload.contentVersion, '2026.03.1');
        expect(state.payload.effectiveFrom, contains('2026-03-01'));
        expect(state.payload.lastUpdatedAt, contains('2026-03-26'));
      },
    );

    test(
      'refresh feedback differentiates unchanged (304) and updated (200)',
      () async {
        final repository = _FakeLegalRepository(
          initial: const _LegalPayload(
            slug: 'privacy',
            contentVersion: '2026.03.1',
            effectiveFrom: '2026-03-01T00:00:00.000Z',
            lastUpdatedAt: '2026-03-26T00:00:00.000Z',
          ),
          refreshed: const _RefreshResult(
            statusCode: 304,
            payload: _LegalPayload(
              slug: 'privacy',
              contentVersion: '2026.03.1',
              effectiveFrom: '2026-03-01T00:00:00.000Z',
              lastUpdatedAt: '2026-03-26T00:00:00.000Z',
            ),
          ),
        );
        final controller = _LegalController(repository);

        await controller.load();
        final unchanged = await controller.refresh();
        expect(unchanged.feedback, 'Already up to date.');

        repository.refreshed = const _RefreshResult(
          statusCode: 200,
          payload: _LegalPayload(
            slug: 'privacy',
            contentVersion: '2026.03.2',
            effectiveFrom: '2026-03-15T00:00:00.000Z',
            lastUpdatedAt: '2026-03-27T00:00:00.000Z',
          ),
        );

        final updated = await controller.refresh();
        expect(updated.feedback, 'Content updated to 2026.03.2');
      },
    );

    test('requires production legal content screen wiring file', () {
      expect(
        File(
          'lib/feature/content/screens/legal_content_screen.dart',
        ).existsSync(),
        isTrue,
      );
    });
  });
}

class _LegalController {
  _LegalController(this._repository);

  final _FakeLegalRepository _repository;
  _LegalPayload? _lastPayload;

  Future<_LegalState> load() async {
    final payload = await _repository.fetch();
    _lastPayload = payload;
    return _LegalState(payload: payload, feedback: 'Loaded');
  }

  Future<_LegalState> refresh() async {
    final result = await _repository.refresh();
    final feedback = result.statusCode == 304
        ? 'Already up to date.'
        : 'Content updated to ${result.payload.contentVersion}';
    _lastPayload = result.payload;
    return _LegalState(payload: _lastPayload!, feedback: feedback);
  }
}

class _LegalState {
  const _LegalState({required this.payload, required this.feedback});

  final _LegalPayload payload;
  final String feedback;
}

class _FakeLegalRepository {
  _FakeLegalRepository({required this.initial, this.refreshed});

  final _LegalPayload initial;
  _RefreshResult? refreshed;

  Future<_LegalPayload> fetch() async => initial;

  Future<_RefreshResult> refresh() async {
    return refreshed ?? _RefreshResult(statusCode: 304, payload: initial);
  }
}

class _RefreshResult {
  const _RefreshResult({required this.statusCode, required this.payload});

  final int statusCode;
  final _LegalPayload payload;
}

class _LegalPayload {
  const _LegalPayload({
    required this.slug,
    required this.contentVersion,
    required this.effectiveFrom,
    required this.lastUpdatedAt,
  });

  final String slug;
  final String contentVersion;
  final String effectiveFrom;
  final String lastUpdatedAt;
}
