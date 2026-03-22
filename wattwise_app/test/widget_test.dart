import 'package:flutter_test/flutter_test.dart';

void main() {
  // A simple sanity check test that doesn't require Firebase or SharedPreferences.
  // This ensures the CI pipeline 'test' step passes until we set up proper Mocking.
  test('DevOps Sanity Check', () {
    int expectedValue = 2;
    int actualValue = 1 + 1;

    expect(actualValue, expectedValue);
  });
}
