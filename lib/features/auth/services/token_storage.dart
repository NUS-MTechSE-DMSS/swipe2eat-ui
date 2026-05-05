import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for storing and retrieving AWS Cognito authentication tokens
class TokenStorage {
  static const String _idTokenKey = 'cognito.idToken';
  static const String _accessTokenKey = 'cognito.accessToken';
  static const String _refreshTokenKey = 'cognito.refreshToken';
  static const String _idTokenExpiresAtKey = 'cognito.idTokenExpiresAt';
  static const String _accessTokenExpiresAtKey = 'cognito.accessTokenExpiresAt';
  static const String _userIdKey = 'cognito.userId';
  static const String _emailKey = 'cognito.email';
  static const String _userCreatedFlagKey = 'user.backendCreated';

  /// Save authentication tokens after successful sign in
  static Future<void> saveTokens({
    required String idToken,
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
    String? userId,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idTokenKey, idToken);
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await _saveTokenExpiries(
      prefs: prefs,
      idToken: idToken,
      accessToken: accessToken,
      expiresIn: expiresIn,
    );

    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }

    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
  }

  /// Update the active session tokens while preserving existing user metadata.
  static Future<void> updateTokens({
    required String idToken,
    required String accessToken,
    int? expiresIn,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idTokenKey, idToken);
    await prefs.setString(_accessTokenKey, accessToken);
    await _saveTokenExpiries(
      prefs: prefs,
      idToken: idToken,
      accessToken: accessToken,
      expiresIn: expiresIn,
    );

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
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

  static Future<DateTime?> getIdTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return _parseExpiresAt(prefs.getString(_idTokenExpiresAtKey));
  }

  static Future<DateTime?> getAccessTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return _parseExpiresAt(prefs.getString(_accessTokenExpiresAtKey));
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
    if (idToken == null || idToken.isEmpty) {
      return false;
    }

    final expiresAt =
        await getIdTokenExpiresAt() ?? extractExpiresAtFromToken(idToken);
    if (expiresAt == null) {
      return true;
    }

    return expiresAt.isAfter(DateTime.now());
  }

  /// Clear all stored tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    await prefs.remove(_idTokenKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_idTokenExpiresAtKey);
    await prefs.remove(_accessTokenExpiresAtKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);

    if (userId != null) {
      await prefs.remove('$_userCreatedFlagKey.$userId');
    }
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

  static Future<String?> getAccessTokenAuthorizationHeader() async {
    final accessToken = await getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      return 'Bearer $accessToken';
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

  static DateTime? extractExpiresAtFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = payloadMap['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveTokenExpiries({
    required SharedPreferences prefs,
    required String idToken,
    required String accessToken,
    int? expiresIn,
  }) async {
    final fallbackExpiry = expiresIn != null && expiresIn > 0
        ? DateTime.now().add(Duration(seconds: expiresIn))
        : null;

    final idTokenExpiry = extractExpiresAtFromToken(idToken) ?? fallbackExpiry;
    final accessTokenExpiry =
        extractExpiresAtFromToken(accessToken) ?? fallbackExpiry;

    if (idTokenExpiry != null) {
      await prefs.setString(
        _idTokenExpiresAtKey,
        idTokenExpiry.toIso8601String(),
      );
    }
    if (accessTokenExpiry != null) {
      await prefs.setString(
        _accessTokenExpiresAtKey,
        accessTokenExpiry.toIso8601String(),
      );
    }
  }

  static DateTime? _parseExpiresAt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
