import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/models/food_item.dart';

void main() {
  group('FoodItem', () {
    test('creates a FoodItem with all required fields', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        distanceLabel: '0.7 mi away',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean', 'Rice Bowl'],
      );

      expect(foodItem.id, '1');
      expect(foodItem.name, 'Bibimbap');
      expect(foodItem.restaurant, 'Seoul Garden');
      expect(foodItem.imageUrl, 'https://example.com/image.jpg');
      expect(foodItem.rating, 4.7);
      expect(foodItem.price, 14.99);
      expect(foodItem.description, 'Korean rice bowl');
      expect(foodItem.distanceLabel, '0.7 mi away');
      expect(foodItem.spiceLevel, 2);
      expect(foodItem.budgetLevel, 2);
      expect(foodItem.tags, ['Korean', 'Rice Bowl']);
    });

    test('creates a FoodItem with different rating values', () {
      final foodItem = FoodItem(
        id: '2',
        name: 'Spicy Tuna Roll',
        restaurant: 'Sakura Sushi House',
        imageUrl: 'https://example.com/tuna.jpg',
        rating: 4.8,
        price: 16.99,
        description: 'Fresh tuna sushi roll',
        distanceLabel: '0.3 mi away',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: ['Japanese', 'Sushi'],
      );

      expect(foodItem.rating, 4.8);
      expect(foodItem.rating > 4.0, true);
      expect(foodItem.rating <= 5.0, true);
    });

    test('creates a FoodItem with minimum spice level', () {
      final foodItem = FoodItem(
        id: '3',
        name: 'Mild Curry',
        restaurant: 'Spice Kitchen',
        imageUrl: 'https://example.com/curry.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Mild spiced curry',
        distanceLabel: '1.2 mi away',
        spiceLevel: 1,
        budgetLevel: 1,
        tags: ['Indian', 'Curry'],
      );

      expect(foodItem.spiceLevel, 1);
      expect(foodItem.budgetLevel, 1);
    });

    test('creates a FoodItem with maximum spice level', () {
      final foodItem = FoodItem(
        id: '4',
        name: 'Fire Chili',
        restaurant: 'Hot Spot',
        imageUrl: 'https://example.com/chili.jpg',
        rating: 4.9,
        price: 13.99,
        description: 'Extremely hot chili',
        distanceLabel: '0.5 mi away',
        spiceLevel: 3,
        budgetLevel: 3,
        tags: ['Thai', 'Spicy'],
      );

      expect(foodItem.spiceLevel, 3);
      expect(foodItem.budgetLevel, 3);
    });

    test('FoodItem with empty tags list', () {
      final foodItem = FoodItem(
        id: '5',
        name: 'Mystery Dish',
        restaurant: 'Surprise Kitchen',
        imageUrl: 'https://example.com/mystery.jpg',
        rating: 3.5,
        price: 9.99,
        description: 'A surprise dish',
        distanceLabel: '2.0 mi away',
        spiceLevel: 2,
        budgetLevel: 1,
        tags: [],
      );

      expect(foodItem.tags, isEmpty);
    });

    test('FoodItem with multiple tags', () {
      final foodItem = FoodItem(
        id: '6',
        name: 'Fusion Bowl',
        restaurant: 'Modern Fusion',
        imageUrl: 'https://example.com/fusion.jpg',
        rating: 4.6,
        price: 15.99,
        description: 'Asian fusion dish',
        distanceLabel: '0.8 mi away',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Asian', 'Fusion', 'Vegetarian', 'Organic', 'Gluten-Free'],
      );

      expect(foodItem.tags.length, 5);
      expect(foodItem.tags.contains('Vegetarian'), true);
      expect(foodItem.tags.contains('Gluten-Free'), true);
    });

    test('FoodItem price comparison', () {
      final foodItem1 = FoodItem(
        id: '7',
        name: 'Budget Item',
        restaurant: 'Budget Eats',
        imageUrl: 'https://example.com/budget.jpg',
        rating: 3.5,
        price: 5.99,
        description: 'Cheap and cheerful',
        distanceLabel: '0.5 mi away',
        spiceLevel: 1,
        budgetLevel: 1,
        tags: ['Cheap'],
      );

      final foodItem2 = FoodItem(
        id: '8',
        name: 'Premium Item',
        restaurant: 'Premium Dining',
        imageUrl: 'https://example.com/premium.jpg',
        rating: 4.9,
        price: 29.99,
        description: 'Luxury dining',
        distanceLabel: '1.0 mi away',
        spiceLevel: 2,
        budgetLevel: 3,
        tags: ['Premium'],
      );

      expect(foodItem1.price < foodItem2.price, true);
      expect(foodItem2.price > foodItem1.price, true);
    });

    test('FoodItem distance parsing', () {
      final foodItem = FoodItem(
        id: '9',
        name: 'Nearby Food',
        restaurant: 'Corner Shop',
        imageUrl: 'https://example.com/nearby.jpg',
        rating: 4.2,
        price: 11.99,
        description: 'Very close',
        distanceLabel: '0.1 mi away',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: [],
      );

      expect(foodItem.distanceLabel.contains('mi'), true);
      expect(foodItem.distanceLabel, '0.1 mi away');
    });
  });
}
