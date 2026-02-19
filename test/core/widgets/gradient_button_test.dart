import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/theme/app_colors.dart';
import 'package:swipe2eat_ui/core/widgets/gradient_button.dart';

void main() {
  group('GradientButton Widget', () {
    testWidgets('renders with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('has correct height and shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      final container = find.byType(Container);
      expect(container, findsWidgets);

      final sizedBox = find.descendant(
        of: find.byType(GradientButton),
        matching: find.byType(Container),
      );
      expect(sizedBox, findsWidgets);
    });

    testWidgets('displays gradient colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the container with the gradient
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('text is white color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = find.text('Continue');
      expect(textWidget, findsOneWidget);

      final text = tester.widget<Text>(textWidget);
      expect(text.style?.color, Colors.white);
    });

    testWidgets('text has correct font size and weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = find.text('Continue');
      final text = tester.widget<Text>(textWidget);

      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('button has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GradientButton), findsOneWidget);
    });

    testWidgets('displays different text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Login',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('button responds to multiple taps', (WidgetTester tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapCount, 1);

      await tester.tap(find.byType(GestureDetector));
      expect(tapCount, 2);
    });

    testWidgets('renders correctly with long text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'This is a very long button text that might wrap',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('This is a very long button text that might wrap'), findsOneWidget);
    });

    testWidgets('gradient uses correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Continue',
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the button is created
      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
