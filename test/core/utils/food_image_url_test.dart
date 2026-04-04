import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/utils/food_image_url.dart';

void main() {
  group('foodImageUrlFromKey', () {
    test('returns null for null or empty keys', () {
      expect(foodImageUrlFromKey(null), isNull);
      expect(foodImageUrlFromKey(''), isNull);
      expect(foodImageUrlFromKey('   '), isNull);
    });

    test('returns full URLs unchanged', () {
      const url = 'https://example.com/images/dish.jpg';
      expect(foodImageUrlFromKey(url), equals(url));
    });

    test('expands raw image keys into the public S3 image URL', () {
      expect(
        foodImageUrlFromKey('pad-thai.jpg'),
        equals(
          'https://swe5006-nus-g3-public-dev-ap-southeast-1-282793424364.s3.ap-southeast-1.amazonaws.com/images/pad-thai.jpg',
        ),
      );
    });
  });
}
