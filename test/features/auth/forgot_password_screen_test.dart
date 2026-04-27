import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/forgot_password_screen.dart';

import '../../test_helpers/http_test_overrides.dart';

void main() {
  group('ForgotPasswordScreen', () {
    late HttpTestOverrides httpOverrides;

    void stubCognitoTarget({
      required String target,
      required StubHttpResponse response,
    }) {
      httpOverrides.addHandler(
        matcher: (request) =>
            request.method == 'POST' &&
            request.uri.toString() ==
                'https://cognito-idp.ap-southeast-1.amazonaws.com/' &&
            request.headers['x-amz-target'] == target,
        handler: (_) => response,
      );
    }

    setUp(() {
      httpOverrides = HttpTestOverrides();
      HttpOverrides.global = httpOverrides;
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    Future<void> pumpScreen(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sign-in': (_) => const Scaffold(body: Text('Sign In Route')),
          },
          home: const ForgotPasswordScreen(),
        ),
      );
    }

    testWidgets('shows reset request state by default', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Code'), findsOneWidget);
      expect(find.text('Reset Code'), findsNothing);
    });

    testWidgets('prefills email when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'user@example.com'),
        ),
      );

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('validates email before requesting a reset code', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(httpOverrides.requests, isEmpty);
    });

    testWidgets(
      'transitions into reset-password state after successfully sending code',
      (tester) async {
        stubCognitoTarget(
          target: 'AWSCognitoIdentityProviderService.ForgotPassword',
          response: StubHttpResponse.json(const {}, statusCode: 200),
        );

        await pumpScreen(tester);

        await tester.enterText(
          find.byType(TextFormField).first,
          'user@example.com',
        );
        await tester.tap(find.text('Send Reset Code'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Your Password'), findsOneWidget);
        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Reset Code'), findsOneWidget);
        expect(
          find.text('Password reset code sent to your email'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows reset-form validation errors after code has been sent', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );

      await pumpScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), '123');
      await tester.enterText(fields.at(2), 'short');
      await tester.enterText(fields.at(3), 'different');
      await tester.ensureVisible(find.text('Reset Password'));
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Code must be 6 digits'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('navigates to sign in after successful password reset', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ConfirmForgotPassword',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );

      await pumpScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), '123456');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');
      await tester.ensureVisible(find.text('Reset Password'));
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In Route'), findsOneWidget);
    });

    testWidgets('renders service errors when password reset fails', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ConfirmForgotPassword',
        response: StubHttpResponse.json({
          '__type': 'CodeMismatchException',
          'message': 'Mismatch',
        }, statusCode: 400),
      );

      await pumpScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), '123456');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');
      await tester.ensureVisible(find.text('Reset Password'));
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid reset code. Please try again'), findsOneWidget);
    });

    testWidgets('shows resend success and failure snackbars in reset state', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );

      await pumpScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend code'));
      await tester.pumpAndSettle();
      expect(
        find.text('Password reset code sent to your email'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));

      httpOverrides.clear();
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: StubHttpResponse.json({
          '__type': 'UserNotFoundException',
          'message': 'No account',
        }, statusCode: 400),
      );

      await tester.tap(find.text('Resend code'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        httpOverrides.requests.single.headers['x-amz-target'],
        'AWSCognitoIdentityProviderService.ForgotPassword',
      );
    });
  });
}
