import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/budget_screen.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/dietary_screen.dart';

void main() {
  group('BudgetScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Finder continueOpacityFinder() {
      return find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(Opacity),
      );
    }

    testWidgets('continue starts disabled until a budget is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetScreen(
            selectedCuisinesLabel: 'Thai, Japanese',
            selectedSpiceLabel: 'Hot',
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(continueOpacityFinder().first);
      expect(opacity.opacity, 0.45);
    });

    testWidgets(
      'selecting a budget enables continue and persists the mapped value',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: BudgetScreen(
              selectedCuisinesLabel: 'Thai, Japanese',
              selectedSpiceLabel: 'Hot',
            ),
          ),
        );

        await tester.tap(find.text('Premium'));
        await tester.pumpAndSettle();

        final opacity = tester.widget<Opacity>(continueOpacityFinder().first);
        expect(opacity.opacity, 1.0);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('prefs.budget'), 'high');
        expect(prefs.getString('prefs.budgetLabel'), 'Premium');
        expect(find.byType(DietaryScreen), findsOneWidget);
      },
    );

    testWidgets('navigation preserves prior selections for the dietary step', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetScreen(
            selectedCuisinesLabel: 'Thai, Japanese',
            selectedSpiceLabel: 'Mild',
          ),
        ),
      );

      await tester.tap(find.text('Mid Range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(DietaryScreen), findsOneWidget);
      expect(find.text('Any dietary preferences?'), findsOneWidget);
    });

    testWidgets('back button pops to the previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BudgetScreen(
                        selectedCuisinesLabel: 'Thai',
                        selectedSpiceLabel: 'Hot',
                      ),
                    ),
                  );
                },
                child: const Text('Open Budget'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Budget'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open Budget'), findsOneWidget);
      expect(find.byType(BudgetScreen), findsNothing);
    });
  });
}
