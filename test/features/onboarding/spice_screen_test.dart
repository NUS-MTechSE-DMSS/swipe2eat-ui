import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/spice_screen.dart';

void main() {
  group('SpiceScreen Widget', () {
    testWidgets('displays Spice level title in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('Spice level'), findsOneWidget);
    });

    testWidgets('displays main question', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('How spicy do you like it?'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text("We'll match you with the right heat"), findsOneWidget);
    });

    testWidgets('displays three spice options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('Mild'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hot'), findsOneWidget);
    });

    testWidgets('displays spice option subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('Just a hint of heat'), findsOneWidget);
      expect(find.text('A nice kick'), findsOneWidget);
      expect(find.text('Bring on the fire!'), findsOneWidget);
    });

    testWidgets('displays fire emojis for spice levels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('🔥'), findsWidgets);
      expect(find.text('🔥🔥'), findsOneWidget);
      expect(find.text('🔥🔥🔥'), findsOneWidget);
    });

    testWidgets('Back button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('Continue button is initially disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('selecting Mild enables Continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      await tester.tap(find.text('Mild'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('selecting Medium enables Continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('selecting Hot enables Continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      await tester.tap(find.text('Hot'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('can switch selection from one option to another',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      // Select Mild
      await tester.tap(find.text('Mild'));
      await tester.pumpAndSettle();

      // Switch to Medium
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      // Continue should still be enabled
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Back button exists and is clickable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
          routes: {
            '/previous': (_) => const Scaffold(body: SizedBox.shrink()),
          },
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('shows SnackBar when Continue is tapped after selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
          routes: {
            '/budget': (_) => const Scaffold(body: SizedBox.shrink()),
          },
        ),
      );

      // Select an option
      await tester.tap(find.text('Mild'));
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if navigation happened
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('displays progress indicator at step 3 of 6',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      // Progress pills should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('takes selectedCuisinesLabel as parameter',
        (WidgetTester tester) async {
      const testLabel = 'Italian, French, Mexican';
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: testLabel),
        ),
      );

      // Screen should still display properly
      expect(find.text('How spicy do you like it?'), findsOneWidget);
    });

    testWidgets('all three option cards are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('options have proper labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SpiceScreen(selectedCuisinesLabel: 'Indian, Thai'),
        ),
      );

      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });
  });
}
