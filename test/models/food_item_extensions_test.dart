import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/models/food_item.dart';

void main() {
  group('FoodItem Model Extensions', () {
    test('food item creates with all fields', () {
      final food = FoodItem(
        id: '1',
        name: 'Pad Thai',
        restaurant: 'Thai Place',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Traditional Thai noodle dish',
        distanceLabel: '0.5 mi away',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Thai', 'Noodles'],
      );

      expect(food.name, equals('Pad Thai'));
      expect(food.rating, equals(4.5));
      expect(food.price, equals(12.99));
      expect(food.spiceLevel, equals(2));
    });

    test('food item with single tag', () {
      final food = FoodItem(
        id: '2',
        name: 'Burger',
        restaurant: 'Burger Joint',
        imageUrl: 'https://example.com/burger.jpg',
        rating: 4.2,
        price: 11.99,
        description: 'Classic burger',
        distanceLabel: '0.3 mi away',
        spiceLevel: 1,
        budgetLevel: 1,
        tags: ['American'],
      );

      expect(food.tags.length, equals(1));
      expect(food.tags.contains('American'), true);
    });

    test('food item with multiple tags', () {
      final food = FoodItem(
        id: '3',
        name: 'Sushi Roll',
        restaurant: 'Sushi Bar',
        imageUrl: 'https://example.com/sushi.jpg',
        rating: 4.8,
        price: 18.99,
        description: 'Fresh sushi',
        distanceLabel: '1.2 mi away',
        spiceLevel: 1,
        budgetLevel: 3,
        tags: ['Japanese', 'Sushi', 'Seafood'],
      );

      expect(food.tags.length, equals(3));
      expect(food.tags, containsAll(['Japanese', 'Sushi', 'Seafood']));
    });

    test('food item budget levels are valid', () {
      for (final level in [1, 2, 3]) {
        final food = FoodItem(
          id: 'test-$level',
          name: 'Food',
          restaurant: 'Restaurant',
          imageUrl: 'https://example.com/food.jpg',
          rating: 4.0,
          price: 15.0 * level,
          description: 'Test food',
          distanceLabel: '0.5 mi away',
          spiceLevel: 1,
          budgetLevel: level,
          tags: [],
        );

        expect(food.budgetLevel, equals(level));
      }
    });

    test('food item spice levels are valid', () {
      for (final level in [1, 2, 3]) {
        final food = FoodItem(
          id: 'spice-$level',
          name: 'Spicy Food',
          restaurant: 'Spicy Restaurant',
          imageUrl: 'https://example.com/spicy.jpg',
          rating: 4.0,
          price: 15.0,
          description: 'Spicy dish',
          distanceLabel: '0.5 mi away',
          spiceLevel: level,
          budgetLevel: 2,
          tags: [],
        );

        expect(food.spiceLevel, equals(level));
      }
    });

    test('food item with empty tags', () {
      final food = FoodItem(
        id: '4',
        name: 'Generic Food',
        restaurant: 'Generic Place',
        imageUrl: 'https://example.com/generic.jpg',
        rating: 3.5,
        price: 10.0,
        description: 'Some food',
        distanceLabel: '0.2 mi away',
        spiceLevel: 1,
        budgetLevel: 1,
        tags: [],
      );

      expect(food.tags, isEmpty);
    });

    test('food item rating validation', () {
      final ratings = [3.0, 3.5, 4.0, 4.5, 4.9];

      for (final rating in ratings) {
        final food = FoodItem(
          id: 'rating-test',
          name: 'Food',
          restaurant: 'Restaurant',
          imageUrl: 'https://example.com/food.jpg',
          rating: rating,
          price: 15.0,
          description: 'Test food',
          distanceLabel: '0.5 mi away',
          spiceLevel: 1,
          budgetLevel: 2,
          tags: [],
        );

        expect(food.rating, equals(rating));
      }
    });

    test('food item distance labels', () {
      final labels = ['0.1 mi away', '0.5 mi away', '1.0 mi away', '2.5 mi away'];

      for (final label in labels) {
        final food = FoodItem(
          id: 'distance-test',
          name: 'Food',
          restaurant: 'Restaurant',
          imageUrl: 'https://example.com/food.jpg',
          rating: 4.0,
          price: 15.0,
          description: 'Test food',
          distanceLabel: label,
          spiceLevel: 1,
          budgetLevel: 2,
          tags: [],
        );

        expect(food.distanceLabel, equals(label));
      }
    });

    test('food item image URL handling', () {
      const validUrl = 'https://example.com/image.jpg';
      final food = FoodItem(
        id: '5',
        name: 'Food',
        restaurant: 'Restaurant',
        imageUrl: validUrl,
        rating: 4.0,
        price: 15.0,
        description: 'Test food',
        distanceLabel: '0.5 mi away',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: [],
      );

      expect(food.imageUrl, equals(validUrl));
    });

    test('food item description handling', () {
      const description = 'Delicious traditional Thai noodle dish with peanut sauce';
      final food = FoodItem(
        id: '6',
        name: 'Pad Thai',
        restaurant: 'Thai Restaurant',
        imageUrl: 'https://example.com/food.jpg',
        rating: 4.7,
        price: 13.99,
        description: description,
        distanceLabel: '0.5 mi away',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Thai'],
      );

      expect(food.description, equals(description));
    });
  });
}
