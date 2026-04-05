import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';

void main() {
  group('TokenStorage.clearTokens', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('clears auth tokens and the per-user backend-created flag', () async {
      SharedPreferences.setMockInitialValues({
        'cognito.idToken': 'id-token',
        'cognito.accessToken': 'access-token',
        'cognito.refreshToken': 'refresh-token',
        'cognito.userId': 'user-123',
        'cognito.email': 'user@example.com',
        'user.backendCreated.user-123': true,
      });

      await TokenStorage.clearTokens();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cognito.idToken'), isNull);
      expect(prefs.getString('cognito.accessToken'), isNull);
      expect(prefs.getString('cognito.refreshToken'), isNull);
      expect(prefs.getString('cognito.userId'), isNull);
      expect(prefs.getString('cognito.email'), isNull);
      expect(prefs.getBool('user.backendCreated.user-123'), isNull);
    });
  });
}
