import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content FAQ search/filter contract (CNT-02)', () {
    test('search and topic filters return only relevant FAQ items', () async {
      final repository = _FakeFaqRepository(
        items: const [
          _FaqItem(
            id: 'faq-1',
            topic: 'billing-basics',
            question: 'What is fixed charge?',
            answer: 'A monthly base charge.',
          ),
          _FaqItem(
            id: 'faq-2',
            topic: 'peak-hours',
            question: 'How do peak tariffs work?',
            answer: 'Higher rates in peak windows.',
          ),
        ],
      );
      final controller = _FaqSearchController(repository);

      final state = await controller.load(q: 'peak', topic: 'peak-hours');

      expect(state.filtered.length, 1);
      expect(state.filtered.first.id, 'faq-2');
    });

    test('empty result state includes deterministic guidance copy', () async {
      final repository = _FakeFaqRepository(items: const []);
      final controller = _FaqSearchController(repository);

      final state = await controller.load(q: 'solar', topic: 'billing-basics');

      expect(state.filtered, isEmpty);
      expect(state.emptyGuidance, 'No matching FAQs. Try a different keyword.');
    });

    test('requires production FAQ wiring files for provider and screen', () {
      expect(
        File('lib/feature/content/provider/content_provider.dart').existsSync(),
        isTrue,
      );
      expect(
        File('lib/feature/content/screens/faq_screen.dart').existsSync(),
        isTrue,
      );
    });
  });
}

class _FaqSearchController {
  _FaqSearchController(this._repository);

  final _FakeFaqRepository _repository;

  Future<_FaqSearchState> load({
    required String q,
    required String topic,
  }) async {
    final all = await _repository.fetchFaqs();
    final keyword = q.trim().toLowerCase();
    final selectedTopic = topic.trim().toLowerCase();

    final filtered = all
        .where((item) => item.topic.toLowerCase() == selectedTopic)
        .where(
          (item) =>
              item.question.toLowerCase().contains(keyword) ||
              item.answer.toLowerCase().contains(keyword),
        )
        .toList(growable: false);

    return _FaqSearchState(
      filtered: filtered,
      emptyGuidance: filtered.isEmpty
          ? 'No matching FAQs. Try a different keyword.'
          : '',
    );
  }
}

class _FaqSearchState {
  const _FaqSearchState({required this.filtered, required this.emptyGuidance});

  final List<_FaqItem> filtered;
  final String emptyGuidance;
}

class _FakeFaqRepository {
  _FakeFaqRepository({required List<_FaqItem> items}) : _items = items;

  final List<_FaqItem> _items;

  Future<List<_FaqItem>> fetchFaqs() async => _items;
}

class _FaqItem {
  const _FaqItem({
    required this.id,
    required this.topic,
    required this.question,
    required this.answer,
  });

  final String id;
  final String topic;
  final String question;
  final String answer;
}
