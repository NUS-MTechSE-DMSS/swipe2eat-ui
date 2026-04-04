import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:swipe2eat_ui/features/auth/services/cognito_service.dart';

void main() {
  group('CognitoService.deleteUser', () {
    test('calls DeleteUser with access token and returns success', () async {
      final client = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('https://cognito-idp.ap-southeast-1.amazonaws.com/'),
        );
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

    test('maps NotAuthorizedException to a retryable message', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            '__type': 'NotAuthorizedException',
            'message': 'Access Token has expired',
          }),
          400,
        );
      });

      final result = await CognitoService.deleteUser(
        accessToken: 'expired-token',
        client: client,
      );

      expect(result['success'], isFalse);
      expect(
        result['error'],
        equals(
          'Your sign-in session expired. Please sign in again and retry deleting your account.',
        ),
      );
    });
  });
}
