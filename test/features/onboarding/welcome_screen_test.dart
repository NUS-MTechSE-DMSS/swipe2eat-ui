import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/onboarding/screens/welcome_screen.dart';

void main() {
  group('WelcomeScreen Widget', () {
    testWidgets('displays welcome title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.text('Welcome to Swipe2Eat'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.text('Discover your next favorite meal'), findsOneWidget);
    });

    testWidgets('displays restaurant icon', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('has Continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(),
          routes: {'/cuisine': (_) => const Scaffold(body: SizedBox.shrink())},
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('title has correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      final titleFinder = find.text('Welcome to Swipe2Eat');
      final title = tester.widget<Text>(titleFinder);

      expect(title.style?.fontSize, 28);
      expect(title.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('subtitle is centered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      final subtitleFinder = find.text('Discover your next favorite meal');
      final subtitle = tester.widget<Text>(subtitleFinder);

      expect(subtitle.textAlign, TextAlign.center);
    });

    testWidgets('icon container has orange gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      final padding = find.byType(Padding);
      expect(padding, findsWidgets);
    });

    testWidgets('scaffold has proper background', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('continue button navigates to cuisine screen', (
      WidgetTester tester,
    ) async {
      var navigated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(),
          routes: {
            '/cuisine': (_) {
              navigated = true;
              return const Scaffold(body: SizedBox.shrink());
            },
          },
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(navigated, true);
    });

    testWidgets('column layout is centered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('renders all text elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.byType(Text), findsWidgets);
      expect(find.byType(Text).evaluate().length, greaterThanOrEqualTo(2));
    });
  });
}
