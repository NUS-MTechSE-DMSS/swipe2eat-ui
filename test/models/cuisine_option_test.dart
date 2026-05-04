import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/models/cuisine_option.dart';

void main() {
  test('CuisineOption stores its display values', () {
    const option = CuisineOption('Thai', '🍜');

    expect(option.name, 'Thai');
    expect(option.emoji, '🍜');
  });
}
