import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/cuisine_screen.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/spice_screen.dart';

void main() {
  group('CuisineScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Finder continueOpacityFinder() {
      return find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(Opacity),
      );
    }

    testWidgets('continue starts disabled until a cuisine is selected', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CuisineScreen()));

      final opacity = tester.widget<Opacity>(continueOpacityFinder().first);
      expect(opacity.opacity, 0.45);
    });

    testWidgets(
      'tapping a cuisine toggles selection state and enables continue',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: CuisineScreen()));

        await tester.tap(find.text('Thai'));
        await tester.pumpAndSettle();

        var opacity = tester.widget<Opacity>(continueOpacityFinder().first);
        expect(opacity.opacity, 1.0);

        await tester.tap(find.text('Thai'));
        await tester.pumpAndSettle();

        opacity = tester.widget<Opacity>(continueOpacityFinder().first);
        expect(opacity.opacity, 0.45);
      },
    );

    testWidgets(
      'continue stores sorted cuisines, navigates, and shows snackbar',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: CuisineScreen()));

        await tester.tap(find.text('Thai'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Japanese'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('prefs.cuisines'),
          equals(['Japanese', 'Thai']),
        );
        expect(find.byType(SpiceScreen), findsOneWidget);
        expect(find.text('Selected: Japanese, Thai'), findsOneWidget);
      },
    );

    testWidgets('back button pops to the previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CuisineScreen(),
                    ),
                  );
                },
                child: const Text('Open Cuisine'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Cuisine'));
      await tester.pumpAndSettle();
      expect(find.byType(CuisineScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open Cuisine'), findsOneWidget);
      expect(find.byType(CuisineScreen), findsNothing);
    });
  });
}
