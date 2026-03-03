import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving AWS Cognito authentication tokens
class TokenStorage {
  static const String _idTokenKey = 'cognito.idToken';
  static const String _accessTokenKey = 'cognito.accessToken';
  static const String _refreshTokenKey = 'cognito.refreshToken';
  static const String _userIdKey = 'cognito.userId';
  static const String _emailKey = 'cognito.email';

  /// Save authentication tokens after successful sign in
  static Future<void> saveTokens({
    required String idToken,
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idTokenKey, idToken);
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    
    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
  }

  /// Get the ID token (used for API authentication)
  static Future<String?> getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_idTokenKey);
  }

  /// Get the access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get the refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Get the stored user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get the stored email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Check if user is logged in (has valid tokens)
  static Future<bool> isLoggedIn() async {
    final idToken = await getIdToken();
    return idToken != null && idToken.isNotEmpty;
  }

  /// Clear all stored tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idTokenKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
  }

  /// Get authorization header value for API requests
  /// Returns "Bearer <idToken>" or null if not logged in
  static Future<String?> getAuthorizationHeader() async {
    final idToken = await getIdToken();
    if (idToken != null && idToken.isNotEmpty) {
      return 'Bearer $idToken';
    }
    return null;
  }
}
