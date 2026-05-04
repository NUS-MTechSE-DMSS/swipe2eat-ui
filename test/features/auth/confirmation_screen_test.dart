import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/confirmation_screen.dart';

import '../../test_helpers/http_test_overrides.dart';

void main() {
  group('ConfirmationScreen', () {
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

    testWidgets('displays the target email address', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfirmationScreen(email: 'user@example.com')),
      );

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets(
      'shows validation error and does not submit invalid verification code',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ConfirmationScreen(email: 'user@example.com'),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '123');
        await tester.tap(find.text('Verify Email'));
        await tester.pumpAndSettle();

        expect(find.text('Code must be 6 digits'), findsOneWidget);
        expect(httpOverrides.requests, isEmpty);
      },
    );

    testWidgets('pops back to the previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sign-in': (_) => const Scaffold(body: Text('Sign In Route')),
          },
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ConfirmationScreen(
                            email: 'user@example.com',
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Confirmation'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Confirmation'));
      await tester.pumpAndSettle();
      expect(find.byType(ConfirmationScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open Confirmation'), findsOneWidget);
      expect(find.byType(ConfirmationScreen), findsNothing);
    });

    testWidgets('navigates to sign in after successful confirmation', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ConfirmSignUp',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sign-in': (_) => const Scaffold(body: Text('Sign In Route')),
          },
          home: const ConfirmationScreen(email: 'user@example.com'),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In Route'), findsOneWidget);
    });

    testWidgets('renders service errors when confirmation fails', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ConfirmSignUp',
        response: StubHttpResponse.json({
          '__type': 'CodeMismatchException',
          'message': 'Mismatch',
        }, statusCode: 400),
      );

      await tester.pumpWidget(
        const MaterialApp(home: ConfirmationScreen(email: 'user@example.com')),
      );

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      expect(
        find.text('Invalid verification code. Please try again'),
        findsOneWidget,
      );
    });

    testWidgets('shows a success snackbar when resending code succeeds', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
        response: StubHttpResponse.json(const {}, statusCode: 200),
      );

      await tester.pumpWidget(
        const MaterialApp(home: ConfirmationScreen(email: 'user@example.com')),
      );

      await tester.tap(find.text("Didn't receive code? Resend"));
      await tester.pumpAndSettle();

      expect(find.text('Verification code sent to your email'), findsOneWidget);
    });

    testWidgets('shows a failure snackbar when resending code fails', (
      tester,
    ) async {
      stubCognitoTarget(
        target: 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
        response: StubHttpResponse.json({
          'message': 'Failed to resend code',
        }, statusCode: 400),
      );

      await tester.pumpWidget(
        const MaterialApp(home: ConfirmationScreen(email: 'user@example.com')),
      );

      await tester.tap(find.text("Didn't receive code? Resend"));
      await tester.pumpAndSettle();

      expect(find.text('Failed to resend code'), findsOneWidget);
    });
  });
}
