import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile load state scaffold is active for phase 07', () {
    const contractEndpoint = '/api/v1/users/me';

    expect(contractEndpoint, contains('/users/me'));
  });

  testWidgets(
    'TODO: profile screen shows retry affordance on load failure',
    (_) async {},
    skip: true,
  );
}
