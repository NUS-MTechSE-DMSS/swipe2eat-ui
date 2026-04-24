import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/sign_up_screen.dart';

void main() {
  group('SignUpScreen Widget', () {
    testWidgets('renders the signup form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Gender'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(InputDecorator, 'Date of Birth'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'City'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        findsOneWidget,
      );
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('email field uses email keyboard type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      final emailField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Email'),
          matching: find.byType(TextField),
        ),
      );

      expect(emailField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('password fields are obscured by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      final passwordField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Password'),
          matching: find.byType(TextField),
        ),
      );
      final confirmPasswordField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Confirm Password'),
          matching: find.byType(TextField),
        ),
      );

      expect(passwordField.obscureText, true);
      expect(confirmPasswordField.obscureText, true);
    });

    testWidgets('allows entering name and email', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Jane Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'jane@example.com',
      );

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
    });

    testWidgets(
      'shows validation errors for missing gender and date of birth',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'),
          'Jane Doe',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'jane@example.com',
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Singapore').last);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'Password123!',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'Password123!',
        );

        await tester.ensureVisible(find.text('Sign Up'));
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Please select your gender'), findsOneWidget);
        expect(find.text('Please select your date of birth'), findsOneWidget);
      },
    );
  });
}
