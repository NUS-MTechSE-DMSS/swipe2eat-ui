import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/config/api_config.dart';
import 'package:swipe2eat_ui/core/services/user_service.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';

void main() {
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
