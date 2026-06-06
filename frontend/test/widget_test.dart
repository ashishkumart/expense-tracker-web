import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker_web/core/utils/formatters.dart';

void main() {
  test('formats dates in Indian day/month/year order', () {
    expect(indianDateFormat.format(DateTime(2026, 6, 5)), '05/06/2026');
  });
}
