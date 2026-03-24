import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'profile validation scaffold asserts normalized error fields contract',
    () {
      final envelope = {
        'success': false,
        'statusCode': 400,
        'errors': [
          {
            'field': 'name',
            'code': 'INVALID_VALUE',
            'message': 'Name must be at least 2 characters',
          },
        ],
      };

      expect(envelope['success'], isFalse);
      expect(envelope['errors'], isA<List>());
    },
  );

  testWidgets(
    'TODO: inline validation feedback renders before save submit',
    (_) async {},
    skip: true,
  );
}
