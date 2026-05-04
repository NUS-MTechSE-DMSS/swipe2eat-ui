import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/onboarding/models/dietary_options.dart';

void main() {
  group('DietaryOptions', () {
    test('parses API payloads into typed lists', () {
      final options = DietaryOptions.fromJson({
        'dietType': ['Omnivore', 'Vegan'],
        'allergens': ['Peanut', 'Soy'],
      });

      expect(options.dietType, equals(['Omnivore', 'Vegan']));
      expect(options.allergens, equals(['Peanut', 'Soy']));
    });

    test('provides empty list fallbacks and static fallback data', () {
      final options = DietaryOptions.fromJson(const {});

      expect(options.dietType, isEmpty);
      expect(options.allergens, isEmpty);
      expect(DietaryOptions.fallback.dietType, contains('Vegetarian'));
      expect(DietaryOptions.fallback.allergens, contains('Peanut'));
    });
  });
}
