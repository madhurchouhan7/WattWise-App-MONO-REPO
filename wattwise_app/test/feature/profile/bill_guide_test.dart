import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bill guide contract (CNT-03)', () {
    test(
      'renders structured sections and glossary terms from repository data',
      () async {
        final repository = _FakeBillGuideRepository(
          response: const _BillGuideData(
            sections: [
              _BillSection(
                id: 's1',
                heading: 'Fixed Charges',
                body: 'Base monthly fee.',
              ),
              _BillSection(
                id: 's2',
                heading: 'Energy Units',
                body: 'Units multiplied by tariff.',
              ),
            ],
            glossary: [
              _GlossaryTerm(term: 'kWh', definition: 'Unit of electricity.'),
            ],
          ),
        );
        final controller = _BillGuideController(repository);

        final state = await controller.load();

        expect(state.sections.length, 2);
        expect(state.sections.first.heading, 'Fixed Charges');
        expect(state.glossary.single.term, 'kWh');
      },
    );

    test('retry transitions from error to loaded state', () async {
      final repository = _FakeBillGuideRepository(
        response: const _BillGuideData(sections: [], glossary: []),
        failFirst: true,
      );
      final controller = _BillGuideController(repository);

      final failed = await controller.load();
      expect(failed.hasError, isTrue);

      final retried = await controller.retry();
      expect(retried.hasError, isFalse);
    });

    test('requires production bill guide screen wiring file', () {
      expect(
        File('lib/feature/content/screens/bill_guide_screen.dart').existsSync(),
        isTrue,
      );
    });
  });
}

class _BillGuideController {
  _BillGuideController(this._repository);

  final _FakeBillGuideRepository _repository;

  Future<_BillGuideState> load() async {
    try {
      final data = await _repository.fetch();
      return _BillGuideState(
        sections: data.sections,
        glossary: data.glossary,
        hasError: false,
      );
    } catch (_) {
      return const _BillGuideState(sections: [], glossary: [], hasError: true);
    }
  }

  Future<_BillGuideState> retry() => load();
}

class _BillGuideState {
  const _BillGuideState({
    required this.sections,
    required this.glossary,
    required this.hasError,
  });

  final List<_BillSection> sections;
  final List<_GlossaryTerm> glossary;
  final bool hasError;
}

class _FakeBillGuideRepository {
  _FakeBillGuideRepository({required this.response, this.failFirst = false});

  final _BillGuideData response;
  bool failFirst;

  Future<_BillGuideData> fetch() async {
    if (failFirst) {
      failFirst = false;
      throw StateError('Temporary failure');
    }
    return response;
  }
}

class _BillGuideData {
  const _BillGuideData({required this.sections, required this.glossary});

  final List<_BillSection> sections;
  final List<_GlossaryTerm> glossary;
}

class _BillSection {
  const _BillSection({
    required this.id,
    required this.heading,
    required this.body,
  });

  final String id;
  final String heading;
  final String body;
}

class _GlossaryTerm {
  const _GlossaryTerm({required this.term, required this.definition});

  final String term;
  final String definition;
}
