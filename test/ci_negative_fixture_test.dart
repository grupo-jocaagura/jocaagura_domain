import 'package:flutter_test/flutter_test.dart';

void main() {
  test('P12 intentional test failure', () {
    expect(true, isFalse, reason: 'P12 negative certification only');
  });
}
