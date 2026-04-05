import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/config/api_config.dart';
import 'package:swipe2eat_ui/core/services/user_service.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';

void main() {
  group('UserService.logoutCurrentUser', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('posts access token to backend logout endpoint', () async {
      await TokenStorage.saveTokens(
        idToken: 'id-token',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-123',
      );

      final client = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('${ApiConfig.baseUrl}/user/logout'),
        );
        expect(request.headers['Authorization'], equals('Bearer access-token'));
        expect(request.headers['Content-Type'], equals('application/json'));

        return http.Response('', 204);
      });

      final loggedOut = await UserService.logoutCurrentUser(client: client);

      expect(loggedOut, isTrue);
    });

    test('returns false when access token is unavailable', () async {
      await TokenStorage.saveTokens(
        idToken: 'id-token',
        accessToken: '',
        refreshToken: 'refresh-token',
        userId: 'user-123',
      );

      final loggedOut = await UserService.logoutCurrentUser();

      expect(loggedOut, isFalse);
    });

    test('refreshes tokens and retries logout after 401', () async {
      await TokenStorage.saveTokens(
        idToken: 'old-id-token',
        accessToken: 'expired-access-token',
        refreshToken: 'refresh-token',
        userId: 'user-123',
      );

      var logoutCalls = 0;
      final logoutClient = MockClient((request) async {
        logoutCalls++;
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('${ApiConfig.baseUrl}/user/logout'),
        );

        if (logoutCalls == 1) {
          expect(
            request.headers['Authorization'],
            equals('Bearer expired-access-token'),
          );
          return http.Response(
            '{"message":"Invalid or expired token","error":"Unauthorized"}',
            401,
          );
        }

        expect(
          request.headers['Authorization'],
          equals('Bearer refreshed-access-token'),
        );
        return http.Response('', 204);
      });

      final cognitoClient = MockClient((request) async {
        expect(request.method, equals('POST'));
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
              'IdToken': 'refreshed-id-token',
              'AccessToken': 'refreshed-access-token',
              'ExpiresIn': 3600,
              'TokenType': 'Bearer',
            },
          }),
          200,
        );
      });

      final loggedOut = await UserService.logoutCurrentUser(
        client: logoutClient,
        cognitoClient: cognitoClient,
      );

      expect(loggedOut, isTrue);
      expect(await TokenStorage.getIdToken(), equals('refreshed-id-token'));
      expect(
        await TokenStorage.getAccessToken(),
        equals('refreshed-access-token'),
      );
      expect(await TokenStorage.getRefreshToken(), equals('refresh-token'));
    });
  });

  group('UserService.deleteCurrentUserInBackend', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('treats 404 as success so Cognito deletion can be retried', () async {
      await TokenStorage.saveTokens(
        idToken: 'id-token',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-123',
      );

      final client = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(
          request.url.toString(),
          equals('${ApiConfig.baseUrl}/user/user-123'),
        );
        expect(request.headers['Authorization'], equals('Bearer access-token'));
        expect(request.headers['X-Id-Token'], equals('id-token'));

        return http.Response('', 404);
      });

      final deleted = await UserService.deleteCurrentUserInBackend(
        client: client,
      );

      expect(deleted, isTrue);
    });

    test('returns false when user identity is unavailable', () async {
      await TokenStorage.saveTokens(
        idToken: 'id-token',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      final deleted = await UserService.deleteCurrentUserInBackend();

      expect(deleted, isFalse);
    });
  });
}
