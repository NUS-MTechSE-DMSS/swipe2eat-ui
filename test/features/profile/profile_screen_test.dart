import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'package:swipe2eat_ui/features/profile/profile_screen.dart';
import 'package:swipe2eat_ui/models/food_item.dart';

void main() {
  group('ProfileScreen logout flow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'cognito.userId': 'user-123',
        'cognito.accessToken': '',
        'cognito.idToken': '',
        'cognito.refreshToken': 'refresh-token',
        'cognito.email': 'user@example.com',
        'user.backendCreated.user-123': true,
      });
      FavoritesStore.instance.clear();
    });

    Future<void> pumpProfile(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sign-in': (_) => const Scaffold(body: Text('Sign In Screen')),
          },
          home: const Scaffold(body: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    FoodItem sampleFavorite() {
      return FoodItem(
        id: 'food-1',
        name: 'Pad Thai',
        restaurant: 'Thai House',
        imageUrl: 'https://example.com/pad-thai.jpg',
        rating: 4.7,
        price: 12.5,
        description: 'Noodles',
        spiceLevel: 2,
        budgetLevel: 2,
        tags: const ['Thai'],
      );
    }

    testWidgets('confirming logout clears local state and navigates', (
      tester,
    ) async {
      FavoritesStore.instance.add(sampleFavorite());

      await pumpProfile(tester);

      final logoutTile = find.text('Logout').first;
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cognito.userId'), isNull);
      expect(prefs.getString('cognito.accessToken'), isNull);
      expect(prefs.getString('cognito.idToken'), isNull);
      expect(prefs.getString('cognito.refreshToken'), isNull);
      expect(prefs.getString('cognito.email'), isNull);
      expect(prefs.getBool('user.backendCreated.user-123'), isNull);
      expect(FavoritesStore.instance.favorites.value, isEmpty);
      expect(find.text('Sign In Screen'), findsOneWidget);
    });

    testWidgets('cancelling logout keeps local state intact', (tester) async {
      FavoritesStore.instance.add(sampleFavorite());

      await pumpProfile(tester);

      final logoutTile = find.text('Logout').first;
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cognito.userId'), equals('user-123'));
      expect(prefs.getString('cognito.refreshToken'), equals('refresh-token'));
      expect(prefs.getBool('user.backendCreated.user-123'), isTrue);
      expect(FavoritesStore.instance.contains('food-1'), isTrue);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Sign In Screen'), findsNothing);
    });
  });
}
