import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'package:swipe2eat_ui/models/food_item.dart';

void main() {
  group('FavoritesStore', () {
    late FavoritesStore store;

    setUp(() {
      store = FavoritesStore.instance;
      store.clear();
    });

    test('singleton instance returns same object', () {
      final instance1 = FavoritesStore.instance;
      final instance2 = FavoritesStore.instance;
      expect(instance1, same(instance2));
    });

    test('initial favorites list is empty', () {
      expect(store.favorites.value, isEmpty);
    });

    test('add() adds a food item to favorites', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean', 'Rice Bowl'],
      );

      store.add(foodItem);

      expect(store.favorites.value.length, 1);
      expect(store.favorites.value[0].id, '1');
      expect(store.favorites.value[0].name, 'Bibimbap');
    });

    test('add() inserts new item at beginning of list', () {
      final foodItem1 = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      final foodItem2 = FoodItem(
        id: '2',
        name: 'Sushi',
        restaurant: 'Sakura',
        imageUrl: 'https://example.com/sushi.jpg',
        rating: 4.8,
        price: 16.99,
        description: 'Fresh sushi',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: ['Japanese'],
      );

      store.add(foodItem1);
      store.add(foodItem2);

      expect(store.favorites.value.length, 2);
      expect(store.favorites.value[0].id, '2'); // Most recently added
      expect(store.favorites.value[1].id, '1');
    });

    test('add() prevents duplicate items', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      store.add(foodItem);
      store.add(foodItem); // Try to add the same item again

      expect(store.favorites.value.length, 1);
    });

    test('removeById() removes item by id', () {
      final foodItem1 = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      final foodItem2 = FoodItem(
        id: '2',
        name: 'Sushi',
        restaurant: 'Sakura',
        imageUrl: 'https://example.com/sushi.jpg',
        rating: 4.8,
        price: 16.99,
        description: 'Fresh sushi',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: ['Japanese'],
      );

      store.add(foodItem1);
      store.add(foodItem2);
      expect(store.favorites.value.length, 2);

      store.removeById('1');

      expect(store.favorites.value.length, 1);
      expect(store.favorites.value[0].id, '2');
    });

    test('removeById() does nothing if id not found', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      store.add(foodItem);
      store.removeById('999'); // Non-existent id

      expect(store.favorites.value.length, 1);
    });

    test('contains() returns true for existing item', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      store.add(foodItem);

      expect(store.contains('1'), true);
    });

    test('contains() returns false for non-existent item', () {
      expect(store.contains('999'), false);
    });

    test('contains() returns false after item is removed', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      store.add(foodItem);
      expect(store.contains('1'), true);

      store.removeById('1');
      expect(store.contains('1'), false);
    });

    test('clear() empties the favorites list', () {
      final foodItem1 = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      final foodItem2 = FoodItem(
        id: '2',
        name: 'Sushi',
        restaurant: 'Sakura',
        imageUrl: 'https://example.com/sushi.jpg',
        rating: 4.8,
        price: 16.99,
        description: 'Fresh sushi',
        spiceLevel: 1,
        budgetLevel: 2,
        tags: ['Japanese'],
      );

      store.add(foodItem1);
      store.add(foodItem2);
      expect(store.favorites.value.length, 2);

      store.clear();

      expect(store.favorites.value, isEmpty);
    });

    test('ValueNotifier notifies listeners on changes', () {
      final foodItem = FoodItem(
        id: '1',
        name: 'Bibimbap',
        restaurant: 'Seoul Garden',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.7,
        price: 14.99,
        description: 'Korean rice bowl',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: ['Korean'],
      );

      var notifyCount = 0;
      store.favorites.addListener(() {
        notifyCount++;
      });

      store.add(foodItem);
      expect(notifyCount, 1);

      store.removeById('1');
      expect(notifyCount, 2);

      store.clear();
      expect(notifyCount, 3);
    });

    test('add() multiple items maintains order', () {
      final items = List.generate(
        5,
        (index) => FoodItem(
          id: '$index',
          name: 'Food $index',
          restaurant: 'Restaurant $index',
          imageUrl: 'https://example.com/image$index.jpg',
          rating: 4.0 + index * 0.1,
          price: 10.0 + index,
          description: 'Description $index',
          spiceLevel: 1,
          budgetLevel: 1,
          tags: [],
        ),
      );

      for (var item in items) {
        store.add(item);
      }

      expect(store.favorites.value.length, 5);
      // Items should be in reverse order (last added first)
      expect(store.favorites.value[0].id, '4');
      expect(store.favorites.value[4].id, '0');
    });
  });
}
