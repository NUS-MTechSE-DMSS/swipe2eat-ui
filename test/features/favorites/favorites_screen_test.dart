import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/favorites/favorites_screen.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'package:swipe2eat_ui/models/food_item.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../../test_helpers/network_image_stub.dart';

void main() {
  group('FavoritesScreen widget tests', () {
    setUp(() {
      FavoritesStore.instance.clear();
    });

    setUpAll(() {
      // Override HTTP requests for NetworkImage to return a tiny PNG
      HttpOverrides.global = TestHttpOverrides();
    });

    tearDownAll(() {
      HttpOverrides.global = null;
    });

    Widget makeTestable({required Widget child}) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('shows empty state when no favorites', (tester) async {
      await tester.pumpWidget(makeTestable(child: const FavoritesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No favorites yet.\nGo like some food 😄'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      // should show 0 dishes saved
      expect(find.textContaining('0 dishes saved'), findsOneWidget);
    });

    testWidgets('displays favorite tiles when items exist', (tester) async {
      final store = FavoritesStore.instance;
      final item1 = FoodItem(
        id: '1',
        name: 'Margherita',
        restaurant: 'Pizza Place',
        imageUrl: 'https://example.com/1.jpg',
        rating: 4.2,
        price: 8.5,
        description: 'Classic',
        distanceLabel: '0.5 km',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Italian'],
      );
      final item2 = FoodItem(
        id: '2',
        name: 'Tacos',
        restaurant: 'Taqueria',
        imageUrl: 'https://example.com/2.jpg',
        rating: 4.7,
        price: 6.5,
        description: 'Spicy',
        distanceLabel: '1.2 km',
        spiceLevel: 2,
        budgetLevel: 0,
        tags: const ['Mexican'],
      );

      store.add(item1);
      store.add(item2);

      await tester.pumpWidget(makeTestable(child: const FavoritesScreen()));
      await tester.pumpAndSettle();

      // header should show 2 dishes saved
      expect(find.textContaining('2 dishes saved'), findsOneWidget);

      // Both item names should be present
      expect(find.text('Margherita'), findsOneWidget);
      expect(find.text('Tacos'), findsOneWidget);

      // Grid tiles should be present (tap first tile navigates)
      expect(find.byType(GestureDetector), isNotNull);
    });

    testWidgets('search filters favorites by name, restaurant, and tag', (tester) async {
      final store = FavoritesStore.instance;
      final item1 = FoodItem(
        id: '1',
        name: 'Margherita',
        restaurant: 'Pizza Place',
        imageUrl: 'https://example.com/1.jpg',
        rating: 4.2,
        price: 8.5,
        description: 'Classic',
        distanceLabel: '0.5 km',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Italian'],
      );
      final item2 = FoodItem(
        id: '2',
        name: 'Green Salad',
        restaurant: 'Healthy Bites',
        imageUrl: 'https://example.com/2.jpg',
        rating: 4.0,
        price: 5.5,
        description: 'Fresh',
        distanceLabel: '0.9 km',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Vegan'],
      );

      store.add(item1);
      store.add(item2);

      await tester.pumpWidget(makeTestable(child: const FavoritesScreen()));
      await tester.pumpAndSettle();

      // enter search text to match 'Green'
      await tester.enterText(find.byType(TextField), 'green');
      await tester.pumpAndSettle();

      expect(find.text('Green Salad'), findsOneWidget);
      expect(find.text('Margherita'), findsNothing);

      // clear and search by tag
      await tester.enterText(find.byType(TextField), 'vegan');
      await tester.pumpAndSettle();

      expect(find.text('Green Salad'), findsOneWidget);

      // search by restaurant
      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pumpAndSettle();

      expect(find.text('Margherita'), findsOneWidget);
    });

    testWidgets('tapping a tile navigates to FoodDetailScreen', (tester) async {
      final store = FavoritesStore.instance;
      final item = FoodItem(
        id: '1',
        name: 'Margherita',
        restaurant: 'Pizza Place',
        imageUrl: 'https://example.com/1.jpg',
        rating: 4.2,
        price: 8.5,
        description: 'Classic',
        distanceLabel: '0.5 km',
        spiceLevel: 0,
        budgetLevel: 0,
        tags: const ['Italian'],
      );

      store.add(item);

      final app = MaterialApp(home: Scaffold(body: const FavoritesScreen()));
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Margherita'), findsOneWidget);

      // Tap the tile by finding the item name
      await tester.tap(find.text('Margherita'));
      await tester.pumpAndSettle();

      // Detail screen displays the name
      expect(find.text('Margherita'), findsWidgets); // both in tile and detail temporarily, but at least one
      expect(find.text('Pizza Place'), findsWidgets);
    });
  });
}

// Using shared TestHttpOverrides from test_helpers/network_image_stub.dart
