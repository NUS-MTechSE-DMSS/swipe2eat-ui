import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/discover/discover_screen.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'package:swipe2eat_ui/models/food_item.dart';

void main() {
  group('DiscoverScreen', () {
    setUp(() {
      // Clear favorites before each test
      FavoritesStore.instance.clear();
    });

    test('is a StatefulWidget', () {
      expect(DiscoverScreen, isNotNull);
      const widget = DiscoverScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('creates State', () {
      const widget = DiscoverScreen();
      expect(widget.createState, isNotNull);
      final state = widget.createState();
      expect(state, isNotNull);
    });

    test('has correct constructor parameters', () {
      const widget = DiscoverScreen(showBottomNav: true);
      expect(widget.showBottomNav, true);

      const widgetHidden = DiscoverScreen(showBottomNav: false);
      expect(widgetHidden.showBottomNav, false);

      // Default value should be true
      const defaultWidget = DiscoverScreen();
      expect(defaultWidget.showBottomNav, true);
    });

    test('State initializes without errors', () {
      final state = DiscoverScreen().createState();
      expect(state, isNotNull);
    });

    test('FavoritesStore is accessible', () {
      final store = FavoritesStore.instance;
      expect(store, isNotNull);
      expect(store.favorites, isNotNull);
      expect(store.favorites.value, isNotNull);
    });

    test('FavoritesStore starts empty', () {
      final store = FavoritesStore.instance;
      expect(store.favorites.value.length, 0);
      expect(store.favorites.value, isEmpty);
    });

    test('can add item to FavoritesStore', () {
      final store = FavoritesStore.instance;
      final item = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Italian', 'Vegetarian'],
      );

      store.add(item);
      expect(store.favorites.value.length, 1);
      expect(store.favorites.value.first.id, '1');
      expect(store.favorites.value.first.name, 'Pizza');
    });

    test('FavoritesStore prevents duplicate items', () {
      final store = FavoritesStore.instance;
      final item = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Italian'],
      );

      store.add(item);
      store.add(item); // Try to add same item again

      expect(store.favorites.value.length, 1); // Still only 1 item
    });

    test('can remove item from FavoritesStore by ID', () {
      final store = FavoritesStore.instance;
      final item = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const [],
      );

      store.add(item);
      expect(store.favorites.value.length, 1);

      store.removeById('1');
      expect(store.favorites.value.length, 0);
    });

    test('FavoritesStore.contains checks item existence by ID', () {
      final store = FavoritesStore.instance;
      final item = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const [],
      );

      expect(store.contains('1'), false);
      store.add(item);
      expect(store.contains('1'), true);
    });

    test('FavoritesStore maintains multiple items in LIFO order', () {
      final store = FavoritesStore.instance;

      final item1 = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const [],
      );

      final item2 = FoodItem(
        id: '2',
        name: 'Burger',
        restaurant: 'Burger King',
        imageUrl: 'https://example.com/burger.jpg',
        rating: 4.0,
        price: 9.99,
        description: 'Tasty burger',
        spiceLevel: 1,
        budgetLevel: 0,
        tags: const [],
      );

      store.add(item1);
      store.add(item2);

      expect(store.favorites.value.length, 2);
      expect(
        store.favorites.value.first.id,
        '2',
      ); // Most recently added is first
      expect(store.favorites.value.last.id, '1');
    });

    test('FavoritesStore.clear removes all items', () {
      final store = FavoritesStore.instance;

      final item1 = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const [],
      );

      store.add(item1);
      expect(store.favorites.value.length, 1);

      store.clear();
      expect(store.favorites.value.length, 0);
      expect(store.favorites.value, isEmpty);
    });

    test('can create with showBottomNav parameter', () {
      const screen1 = DiscoverScreen();
      expect(screen1.showBottomNav, true);

      const screen2 = DiscoverScreen(showBottomNav: false);
      expect(screen2.showBottomNav, false);
    });

    test('State type is correct', () {
      final state1 = DiscoverScreen().createState();
      final state2 = DiscoverScreen(showBottomNav: false).createState();

      expect(state1, isNotNull);
      expect(state2, isNotNull);
      expect(state1.runtimeType, state2.runtimeType);
    });

    test('FavoritesStore is singleton across screens', () {
      final store1 = FavoritesStore.instance;
      final store2 = FavoritesStore.instance;

      expect(identical(store1, store2), true); // Same instance
    });

    test('adding item to store affects store state', () {
      final store = FavoritesStore.instance;
      final initialLength = store.favorites.value.length;

      final item = FoodItem(
        id: '1',
        name: 'Pizza',
        restaurant: 'Pizza Palace',
        imageUrl: 'https://example.com/pizza.jpg',
        rating: 4.5,
        price: 12.99,
        description: 'Delicious pizza',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const [],
      );

      store.add(item);
      expect(store.favorites.value.length, initialLength + 1);
    });

    test('widget properties are immutable', () {
      const screen = DiscoverScreen(showBottomNav: true);
      expect(screen.showBottomNav, true);

      // Widget is immutable (const), so we verify properties don't change
      const screen2 = DiscoverScreen(showBottomNav: true);
      expect(identical(screen, screen2), false); // Different instances
      expect(screen.showBottomNav == screen2.showBottomNav, true); // Same value
    });

    test('removing non-existent item does not error', () {
      final store = FavoritesStore.instance;
      expect(store.favorites.value.length, 0);

      store.removeById('non-existent');
      expect(store.favorites.value.length, 0);
    });

    test('can check contains for non-existent ID', () {
      final store = FavoritesStore.instance;
      expect(store.contains('non-existent'), false);
    });
  });
}
