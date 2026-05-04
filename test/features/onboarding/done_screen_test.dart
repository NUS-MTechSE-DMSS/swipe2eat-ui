import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/config/api_config.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/done_screen.dart';

import '../../test_helpers/http_test_overrides.dart';

void main() {
  group('DoneScreen', () {
    late HttpTestOverrides httpOverrides;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      httpOverrides = HttpTestOverrides();
      HttpOverrides.global = httpOverrides;
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    Future<void> pumpDone(
      WidgetTester tester, {
      required String budget,
      required String allergens,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {'/main': (_) => const Scaffold(body: Text('Main Route'))},
          home: DoneScreen(
            selectedCuisinesLabel: 'Thai, Japanese',
            selectedSpiceLabel: 'Hot',
            selectedBudget: budget,
            selectedDietType: 'Vegetarian',
            selectedAllergensLabel: allergens,
          ),
        ),
      );
    }

    testWidgets('renders selected values and budget symbols', (tester) async {
      await pumpDone(tester, budget: 'Mid Range', allergens: 'Peanut, Soy');

      expect(find.text("You're all set!"), findsOneWidget);
      expect(find.text('Thai, Japanese'), findsOneWidget);
      expect(find.text('Diet: Vegetarian'), findsOneWidget);
      expect(find.text('Allergens: Peanut, Soy'), findsOneWidget);
      expect(find.text('Hot'), findsOneWidget);
      expect(find.text(r'$$'), findsOneWidget);

      for (final entry in const {
        'Budget Friendly': r'$',
        'Mid Range': r'$$',
        'Premium': r'$$$',
      }.entries) {
        await pumpDone(tester, budget: entry.key, allergens: 'None');
        expect(find.text(entry.value), findsOneWidget);
      }
    });

    testWidgets('back button pops to previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoneScreen(
                        selectedCuisinesLabel: 'Thai',
                        selectedSpiceLabel: 'Hot',
                        selectedBudget: 'Premium',
                        selectedDietType: 'Vegetarian',
                        selectedAllergensLabel: 'None',
                      ),
                    ),
                  );
                },
                child: const Text('Open Done'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Done'));
      await tester.pumpAndSettle();
      expect(find.byType(DoneScreen), findsOneWidget);

      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Open Done'), findsOneWidget);
      expect(find.byType(DoneScreen), findsNothing);
    });

    testWidgets(
      'syncs preferences and navigates to main when backend updates succeed',
      (tester) async {
        await TokenStorage.saveTokens(
          idToken: 'id-token',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          userId: 'user-123',
        );

        httpOverrides.addResponse(
          method: 'PUT',
          url: '${ApiConfig.preferenceBaseUrl}/users/user-123',
          response: const StubHttpResponse(statusCode: 204, body: '{}'),
        );
        httpOverrides.addResponse(
          method: 'PUT',
          url: '${ApiConfig.preferenceBaseUrl}/dietary/users/user-123',
          response: const StubHttpResponse(statusCode: 204, body: '{}'),
        );

        await pumpDone(tester, budget: 'Mid Range', allergens: 'None');

        await tester.ensureVisible(find.text('Start Swiping'));
        await tester.tap(find.text('Start Swiping'));
        await tester.pumpAndSettle();

        expect(find.text('Main Route'), findsOneWidget);
        expect(find.text('Preferences saved. Go to Discover.'), findsOneWidget);
        expect(httpOverrides.requests, hasLength(2));
        expect(
          jsonDecode(httpOverrides.requests[0].body),
          equals({
            'cuisines': ['Thai', 'Japanese'],
            'budget': 'medium',
            'spiceLevel': 3,
          }),
        );
        expect(
          jsonDecode(httpOverrides.requests[1].body),
          equals({'dietType': 'Vegetarian', 'allergies': <String>[]}),
        );
      },
    );

    testWidgets('falls back to local persistence when backend sync fails', (
      tester,
    ) async {
      await pumpDone(tester, budget: 'Premium', allergens: 'Peanut, Soy');

      await tester.ensureVisible(find.text('Start Swiping'));
      await tester.tap(find.text('Start Swiping'));
      await tester.pumpAndSettle();

      expect(find.text('Main Route'), findsOneWidget);
      expect(
        find.text('Preferences saved locally. Backend sync failed.'),
        findsOneWidget,
      );
      expect(httpOverrides.requests, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('prefs.cuisines'),
        equals(['Thai', 'Japanese']),
      );
      expect(prefs.getString('prefs.budget'), 'high');
      expect(prefs.getString('prefs.spice'), 'Hot');
      expect(prefs.getString('prefs.dietType'), 'Vegetarian');
      expect(prefs.getStringList('prefs.allergens'), equals(['Peanut', 'Soy']));
    });
  });
}
