import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/features/auth/services/auth_session.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';

String _jwtWithExp(DateTime expiresAt, {String sub = 'user-123'}) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  final exp = expiresAt.millisecondsSinceEpoch ~/ 1000;
  return '${encode({'alg': 'none'})}.${encode({'sub': sub, 'exp': exp})}.sig';
}

http.Response _refreshResponse({
  required String idToken,
  required String accessToken,
}) {
  return http.Response(
    jsonEncode({
      'AuthenticationResult': {
        'IdToken': idToken,
        'AccessToken': accessToken,
        'ExpiresIn': 3600,
        'TokenType': 'Bearer',
      },
    }),
    200,
  );
}

void main() {
  group('AuthSession.ensureFreshSession', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('does not refresh when tokens are fresh', () async {
      final freshToken = _jwtWithExp(
        DateTime.now().add(const Duration(minutes: 30)),
      );
      await TokenStorage.saveTokens(
        idToken: freshToken,
        accessToken: freshToken,
        refreshToken: 'refresh-token',
      );

      final client = MockClient((_) async {
        fail('refresh should not be called for fresh tokens');
      });

      final result = await AuthSession.ensureFreshSession(
        cognitoClient: client,
        redirectOnFailure: false,
      );

      expect(result, isTrue);
    });

    test('refreshes when tokens are inside the expiry buffer', () async {
      final staleToken = _jwtWithExp(
        DateTime.now().add(const Duration(minutes: 2)),
      );
      final refreshedToken = _jwtWithExp(
        DateTime.now().add(const Duration(hours: 1)),
      );
      await TokenStorage.saveTokens(
        idToken: staleToken,
        accessToken: staleToken,
        refreshToken: 'refresh-token',
      );

      var refreshCalls = 0;
      final client = MockClient((request) async {
        refreshCalls++;
        expect(
          jsonDecode(request.body),
          containsPair('AuthFlow', 'REFRESH_TOKEN_AUTH'),
        );
        return _refreshResponse(
          idToken: refreshedToken,
          accessToken: refreshedToken,
        );
      });

      final result = await AuthSession.ensureFreshSession(
        cognitoClient: client,
        redirectOnFailure: false,
      );

      expect(result, isTrue);
      expect(refreshCalls, equals(1));
      expect(await TokenStorage.getIdToken(), equals(refreshedToken));
    });

    test('deduplicates concurrent refreshes', () async {
      final staleToken = _jwtWithExp(
        DateTime.now().add(const Duration(minutes: 2)),
      );
      final refreshedToken = _jwtWithExp(
        DateTime.now().add(const Duration(hours: 1)),
      );
      await TokenStorage.saveTokens(
        idToken: staleToken,
        accessToken: staleToken,
        refreshToken: 'refresh-token',
      );

      var refreshCalls = 0;
      final client = MockClient((_) async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _refreshResponse(
          idToken: refreshedToken,
          accessToken: refreshedToken,
        );
      });

      final results = await Future.wait([
        AuthSession.ensureFreshSession(
          cognitoClient: client,
          redirectOnFailure: false,
        ),
        AuthSession.ensureFreshSession(
          cognitoClient: client,
          redirectOnFailure: false,
        ),
      ]);

      expect(results, equals([true, true]));
      expect(refreshCalls, equals(1));
    });

    test('clears tokens when refresh token is expired', () async {
      final staleToken = _jwtWithExp(
        DateTime.now().add(const Duration(minutes: 2)),
      );
      await TokenStorage.saveTokens(
        idToken: staleToken,
        accessToken: staleToken,
        refreshToken: 'refresh-token',
      );

      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            '__type': 'NotAuthorizedException',
            'message': 'Refresh Token has expired',
          }),
          400,
        ),
      );

      final result = await AuthSession.ensureFreshSession(
        cognitoClient: client,
        redirectOnFailure: true,
      );

      expect(result, isFalse);
      expect(await TokenStorage.getIdToken(), isNull);
      expect(await TokenStorage.getAccessToken(), isNull);
      expect(await TokenStorage.getRefreshToken(), isNull);
    });
  });
}
