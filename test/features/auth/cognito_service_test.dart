import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:swipe2eat_ui/features/auth/services/cognito_service.dart';

import '../../test_helpers/http_test_overrides.dart';

void main() {
  const cognitoUrl = 'https://cognito-idp.ap-southeast-1.amazonaws.com/';

  group('CognitoService static HTTP flows', () {
    late HttpTestOverrides httpOverrides;

    void stubTarget({
      required String target,
      required StubHttpResponse response,
    }) {
      httpOverrides.addHandler(
        matcher: (request) =>
            request.method == 'POST' &&
            request.uri.toString() == cognitoUrl &&
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

    test(
      'signUp sends all provided attributes and returns confirmation requirement',
      () async {
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.SignUp',
          response: StubHttpResponse.json({
            'UserSub': 'user-sub-123',
            'UserConfirmed': false,
          }),
        );

        final result = await CognitoService.signUp(
          email: 'user@example.com',
          password: 'Password123!',
          name: 'Jane Doe',
          city: 'Singapore',
          gender: 'female',
          dateOfBirth: DateTime(1995, 4, 12),
        );

        expect(result['success'], isTrue);
        expect(result['userId'], 'user-sub-123');
        expect(result['requiresConfirmation'], isTrue);

        final request = httpOverrides.requests.single;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['Username'], 'user@example.com');
        expect(body['Password'], 'Password123!');
        expect(
          body['UserAttributes'],
          containsAll(<Object>[
            {'Name': 'email', 'Value': 'user@example.com'},
            {'Name': 'name', 'Value': 'Jane Doe'},
            {'Name': 'gender', 'Value': 'female'},
            {'Name': 'birthdate', 'Value': '1995-04-12'},
            {'Name': 'custom:City', 'Value': 'Singapore'},
          ]),
        );
      },
    );

    test('signUp maps common Cognito failures and network errors', () async {
      final cases = <({String type, String message, String expected})>[
        (
          type: 'UsernameExistsException',
          message: 'Exists',
          expected: 'An account with this email already exists',
        ),
        (
          type: 'InvalidPasswordException',
          message: 'Weak password',
          expected:
              'Password does not meet requirements. Use at least 8 characters with uppercase, lowercase, numbers, and special characters',
        ),
        (
          type: 'InvalidParameterException',
          message: 'custom:City schema mismatch',
          expected:
              'Custom attribute error. Please verify custom:City attribute exists in Cognito User Pool settings',
        ),
        (
          type: 'TooManyRequestsException',
          message: 'Slow down',
          expected: 'Too many requests. Please try again later',
        ),
      ];

      for (final testCase in cases) {
        httpOverrides.clear();
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.SignUp',
          response: StubHttpResponse.json({
            '__type': testCase.type,
            'message': testCase.message,
          }, statusCode: 400),
        );

        final result = await CognitoService.signUp(
          email: 'user@example.com',
          password: 'Password123!',
        );

        expect(result['success'], isFalse);
        expect(result['error'], testCase.expected);
      }

      httpOverrides.clear();
      final networkFailure = await CognitoService.signUp(
        email: 'user@example.com',
        password: 'Password123!',
      );
      expect(networkFailure['success'], isFalse);
      expect(
        networkFailure['error'],
        'Network error. Please check your connection and try again',
      );
    });

    test(
      'confirmSignUp returns success and maps verification errors',
      () async {
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.ConfirmSignUp',
          response: const StubHttpResponse(statusCode: 200, body: '{}'),
        );

        final success = await CognitoService.confirmSignUp(
          email: 'user@example.com',
          confirmationCode: '123456',
        );

        expect(success['success'], isTrue);

        final cases = <({String type, String expected})>[
          (
            type: 'CodeMismatchException',
            expected: 'Invalid verification code. Please try again',
          ),
          (
            type: 'ExpiredCodeException',
            expected: 'Verification code has expired. Request a new one',
          ),
          (
            type: 'NotAuthorizedException',
            expected: 'User is already confirmed',
          ),
        ];

        for (final testCase in cases) {
          httpOverrides.clear();
          stubTarget(
            target: 'AWSCognitoIdentityProviderService.ConfirmSignUp',
            response: StubHttpResponse.json({
              '__type': testCase.type,
              'message': 'error',
            }, statusCode: 400),
          );

          final result = await CognitoService.confirmSignUp(
            email: 'user@example.com',
            confirmationCode: '123456',
          );

          expect(result['success'], isFalse);
          expect(result['error'], testCase.expected);
        }
      },
    );

    test(
      'resendConfirmationCode returns success and backend failure message',
      () async {
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
          response: const StubHttpResponse(statusCode: 200, body: '{}'),
        );

        final success = await CognitoService.resendConfirmationCode(
          email: 'user@example.com',
        );
        expect(success['success'], isTrue);

        httpOverrides.clear();
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
          response: StubHttpResponse.json({
            'message': 'Failed to resend code',
          }, statusCode: 400),
        );

        final failure = await CognitoService.resendConfirmationCode(
          email: 'user@example.com',
        );
        expect(failure['success'], isFalse);
        expect(failure['error'], 'Failed to resend code');
      },
    );

    test('forgotPassword returns success and maps common failures', () async {
      stubTarget(
        target: 'AWSCognitoIdentityProviderService.ForgotPassword',
        response: const StubHttpResponse(statusCode: 200, body: '{}'),
      );

      final success = await CognitoService.forgotPassword(
        email: 'user@example.com',
      );
      expect(success['success'], isTrue);

      final cases = <({String type, String expected})>[
        (
          type: 'UserNotFoundException',
          expected: 'No account found for this email',
        ),
        (
          type: 'InvalidParameterException',
          expected: 'Please enter a valid email address',
        ),
        (
          type: 'TooManyRequestsException',
          expected: 'Too many requests. Please try again later',
        ),
      ];

      for (final testCase in cases) {
        httpOverrides.clear();
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.ForgotPassword',
          response: StubHttpResponse.json({
            '__type': testCase.type,
            'message': 'error',
          }, statusCode: 400),
        );

        final result = await CognitoService.forgotPassword(
          email: 'user@example.com',
        );

        expect(result['success'], isFalse);
        expect(result['error'], testCase.expected);
      }

      httpOverrides.clear();
      final networkFailure = await CognitoService.forgotPassword(
        email: 'user@example.com',
      );
      expect(networkFailure['success'], isFalse);
      expect(
        networkFailure['error'],
        'Network error. Please check your connection and try again',
      );
    });

    test(
      'confirmForgotPassword returns success and maps reset failures',
      () async {
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.ConfirmForgotPassword',
          response: const StubHttpResponse(statusCode: 200, body: '{}'),
        );

        final success = await CognitoService.confirmForgotPassword(
          email: 'user@example.com',
          confirmationCode: '123456',
          newPassword: 'Password123!',
        );
        expect(success['success'], isTrue);

        final cases = <({String type, String expected})>[
          (
            type: 'CodeMismatchException',
            expected: 'Invalid reset code. Please try again',
          ),
          (
            type: 'ExpiredCodeException',
            expected: 'Reset code has expired. Request a new one',
          ),
          (
            type: 'InvalidPasswordException',
            expected:
                'Password does not meet requirements. Use at least 8 characters with uppercase, lowercase, numbers, and special characters',
          ),
          (
            type: 'UserNotFoundException',
            expected: 'No account found for this email',
          ),
        ];

        for (final testCase in cases) {
          httpOverrides.clear();
          stubTarget(
            target: 'AWSCognitoIdentityProviderService.ConfirmForgotPassword',
            response: StubHttpResponse.json({
              '__type': testCase.type,
              'message': 'error',
            }, statusCode: 400),
          );

          final result = await CognitoService.confirmForgotPassword(
            email: 'user@example.com',
            confirmationCode: '123456',
            newPassword: 'Password123!',
          );

          expect(result['success'], isFalse);
          expect(result['error'], testCase.expected);
        }
      },
    );

    test(
      'signIn returns tokens, challenge flow, mapped errors, and network fallback',
      () async {
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.InitiateAuth',
          response: StubHttpResponse.json({
            'AuthenticationResult': {
              'IdToken': 'id-token',
              'AccessToken': 'access-token',
              'RefreshToken': 'refresh-token',
              'ExpiresIn': 3600,
              'TokenType': 'Bearer',
            },
          }),
        );

        final success = await CognitoService.signIn(
          email: 'user@example.com',
          password: 'Password123!',
        );
        expect(success['success'], isTrue);
        expect(success['idToken'], 'id-token');

        httpOverrides.clear();
        stubTarget(
          target: 'AWSCognitoIdentityProviderService.InitiateAuth',
          response: StubHttpResponse.json({
            'ChallengeName': 'NEW_PASSWORD_REQUIRED',
          }),
        );

        final challenge = await CognitoService.signIn(
          email: 'user@example.com',
          password: 'Password123!',
        );
        expect(challenge['success'], isFalse);
        expect(challenge['requiresChallenge'], isTrue);
        expect(challenge['challenge'], 'NEW_PASSWORD_REQUIRED');

        final cases = <({String type, String expected})>[
          (
            type: 'NotAuthorizedException',
            expected: 'Incorrect email or password',
          ),
          (
            type: 'UserNotConfirmedException',
            expected: 'Please verify your email before signing in',
          ),
          (
            type: 'UserNotFoundException',
            expected: 'No account found with this email',
          ),
          (
            type: 'TooManyRequestsException',
            expected: 'Too many attempts. Please try again later',
          ),
        ];

        for (final testCase in cases) {
          httpOverrides.clear();
          stubTarget(
            target: 'AWSCognitoIdentityProviderService.InitiateAuth',
            response: StubHttpResponse.json({
              '__type': testCase.type,
              'message': 'error',
            }, statusCode: 400),
          );

          final result = await CognitoService.signIn(
            email: 'user@example.com',
            password: 'Password123!',
          );

          expect(result['success'], isFalse);
          expect(result['error'], testCase.expected);
        }

        httpOverrides.clear();
        final networkFailure = await CognitoService.signIn(
          email: 'user@example.com',
          password: 'Password123!',
        );
        expect(networkFailure['success'], isFalse);
        expect(
          networkFailure['error'],
          'Network error. Please check your connection and try again',
        );
      },
    );
  });

  group('CognitoService.refreshSession', () {
    test('refreshes session with REFRESH_TOKEN_AUTH', () async {
      final client = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.headers['X-Amz-Target'],
          equals('AWSCognitoIdentityProviderService.InitiateAuth'),
        );
        expect(
          jsonDecode(request.body),
          equals({
            'AuthFlow': 'REFRESH_TOKEN_AUTH',
            'ClientId': '1d1jkchdvgt5tldbb0hivruird',
            'AuthParameters': {'REFRESH_TOKEN': 'refresh-token'},
          }),
        );

        return http.Response(
          jsonEncode({
            'AuthenticationResult': {
              'IdToken': 'new-id-token',
              'AccessToken': 'new-access-token',
              'ExpiresIn': 3600,
              'TokenType': 'Bearer',
            },
          }),
          200,
        );
      });

      final result = await CognitoService.refreshSession(
        refreshToken: 'refresh-token',
        client: client,
      );

      expect(result['success'], isTrue);
      expect(result['idToken'], equals('new-id-token'));
      expect(result['accessToken'], equals('new-access-token'));
      expect(result['refreshToken'], isNull);
    });

    test(
      'handles missing auth result, mapped failures, and network exceptions',
      () async {
        final missingAuthClient = MockClient(
          (_) async => http.Response('{}', 200),
        );
        final missingAuth = await CognitoService.refreshSession(
          refreshToken: 'refresh-token',
          client: missingAuthClient,
        );
        expect(missingAuth['success'], isFalse);

        final notAuthorizedClient = MockClient(
          (_) async => http.Response(
            jsonEncode({
              '__type': 'NotAuthorizedException',
              'message': 'Expired',
            }),
            400,
          ),
        );
        final notAuthorized = await CognitoService.refreshSession(
          refreshToken: 'refresh-token',
          client: notAuthorizedClient,
        );
        expect(
          notAuthorized['error'],
          'Your sign-in session has expired. Please sign in again.',
        );

        final networkClient = MockClient(
          (_) async => throw const SocketException('offline'),
        );
        final networkFailure = await CognitoService.refreshSession(
          refreshToken: 'refresh-token',
          client: networkClient,
        );
        expect(networkFailure['success'], isFalse);
        expect(
          networkFailure['error'],
          'Network error. Please check your connection and try again',
        );
      },
    );
  });

  group('CognitoService.deleteUser', () {
    test('calls DeleteUser with access token and returns success', () async {
      final client = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.toString(), equals(cognitoUrl));
        expect(
          request.headers['X-Amz-Target'],
          equals('AWSCognitoIdentityProviderService.DeleteUser'),
        );
        expect(
          request.headers['Content-Type'],
          equals('application/x-amz-json-1.1'),
        );
        expect(
          jsonDecode(request.body),
          equals({'AccessToken': 'access-token'}),
        );

        return http.Response('{}', 200);
      });

      final result = await CognitoService.deleteUser(
        accessToken: 'access-token',
        client: client,
      );

      expect(result['success'], isTrue);
    });

    test('maps delete-user errors and network exceptions', () async {
      final cases = <({String type, String expected})>[
        (
          type: 'NotAuthorizedException',
          expected:
              'Your sign-in session expired. Please sign in again and retry deleting your account.',
        ),
        (
          type: 'UserNotFoundException',
          expected: 'Your sign-in account was already deleted.',
        ),
        (
          type: 'TooManyRequestsException',
          expected: 'Too many requests. Please try again later.',
        ),
      ];

      for (final testCase in cases) {
        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({'__type': testCase.type, 'message': 'error'}),
            400,
          ),
        );
        final result = await CognitoService.deleteUser(
          accessToken: 'access-token',
          client: client,
        );
        expect(result['success'], isFalse);
        expect(result['error'], testCase.expected);
      }

      final networkClient = MockClient(
        (_) async => throw const SocketException('offline'),
      );
      final networkFailure = await CognitoService.deleteUser(
        accessToken: 'access-token',
        client: networkClient,
      );
      expect(networkFailure['success'], isFalse);
      expect(
        networkFailure['error'],
        'Network error. Please check your connection and try again',
      );
    });
  });
}
