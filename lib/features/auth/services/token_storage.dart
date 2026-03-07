import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/user_service.dart';

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
    
    // Clear user backend creation flag
    await UserService.clearUserCreatedFlag();
  }

  /// Get authorization header value for API requests
  /// Returns Bearer token or null if not logged in
  static Future<String?> getAuthorizationHeader() async {
    final idToken = await getIdToken();
    if (idToken != null && idToken.isNotEmpty) {
      return 'Bearer $idToken';
    }
    return null;
  }

  /// Extract userId (sub claim) from JWT IdToken
  /// Returns null if token is invalid or userId cannot be extracted
  static String? extractUserIdFromToken(String idToken) {
    try {
      // JWT format: header.payload.signature
      final parts = idToken.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed for base64 decoding
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));
      
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      
      // Extract 'sub' claim which is the userId in Cognito
      return payloadMap['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
