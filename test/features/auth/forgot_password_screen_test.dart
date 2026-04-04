import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Widget', () {
    testWidgets('shows reset request state by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Code'), findsOneWidget);
      expect(find.text('Reset Code'), findsNothing);
    });

    testWidgets('prefills email when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'user@example.com'),
        ),
      );

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('has email input field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
