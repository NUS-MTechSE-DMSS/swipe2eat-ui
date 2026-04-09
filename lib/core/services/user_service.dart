import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/cognito_service.dart';
import '../../features/auth/services/token_storage.dart';
import '../config/api_config.dart';

/// Service for managing user operations with the backend
class UserService {
  static const String _userCreatedFlagKey = 'user.backendCreated';

  /// Creates a user in the backend after successful Cognito signup
  /// This should be called after the first successful sign-in
  ///
  /// Backend extracts the user ID (sub) from the JWT token and creates
  /// the user record in the database.
  ///
  /// Returns true if the user was created successfully or already exists,
  /// false if there was an error.
  static Future<bool> createUserInBackend() async {
    try {
      // Check if we've already created this user in the backend
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        return false;
      }

      // Check local flag to avoid unnecessary API calls
      final prefs = await SharedPreferences.getInstance();
      final userCreatedKey = '$_userCreatedFlagKey.$userId';
      final alreadyCreated = prefs.getBool(userCreatedKey) ?? false;

      if (alreadyCreated) {
        // User already created in backend, skip
        return true;
      }

      // Get both Cognito tokens for backend authentication
      final accessToken = await TokenStorage.getAccessToken();
      final idToken = await TokenStorage.getIdToken();
      if (accessToken == null ||
          accessToken.isEmpty ||
          idToken == null ||
          idToken.isEmpty) {
        return false;
      }

      // Build headers with both Authorization (access token) and ID token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'X-Id-Token': idToken,
      };

      // Call backend to create user
      final uri = Uri.parse('${ApiConfig.baseUrl}/user/create-user');
      final response = await http
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      // Backend returns 201 CREATED on success
      if (response.statusCode == 201) {
        // Mark user as created in local storage
        await prefs.setBool(userCreatedKey, true);
        return true;
      } else if (response.statusCode == 409 || response.statusCode == 200) {
        // User already exists in backend (409 Conflict) or other success case
        await prefs.setBool(userCreatedKey, true);
        return true;
      } else {
        // Other error codes indicate failure
        return false;
      }
    } catch (e) {
      // Network errors or timeouts
      return false;
    }
  }

  /// Logs out the currently signed-in user in the backend.
  /// Uses the Cognito access token so the backend can trigger global sign-out.
  ///
  /// Returns true if the backend logout succeeds.
  static Future<bool> logoutCurrentUser({
    http.Client? client,
    http.Client? cognitoClient,
  }) async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null || accessToken.trim().isEmpty) {
        return false;
      }

      final initialResponse = await _sendLogoutRequest(
        accessToken: accessToken,
        client: client,
      );
      if (initialResponse.statusCode == 204) {
        return true;
      }
      if (initialResponse.statusCode != 401) {
        return false;
      }

      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        return false;
      }

      final refreshResult = await CognitoService.refreshSession(
        refreshToken: refreshToken,
        client: cognitoClient,
      );
      if (refreshResult['success'] != true) {
        return false;
      }

      final refreshedAccessToken = refreshResult['accessToken'] as String?;
      final refreshedIdToken = refreshResult['idToken'] as String?;
      if (refreshedAccessToken == null ||
          refreshedAccessToken.isEmpty ||
          refreshedIdToken == null ||
          refreshedIdToken.isEmpty) {
        return false;
      }

      await TokenStorage.updateTokens(
        idToken: refreshedIdToken,
        accessToken: refreshedAccessToken,
        refreshToken: refreshResult['refreshToken'] as String?,
      );

      final retryResponse = await _sendLogoutRequest(
        accessToken: refreshedAccessToken,
        client: client,
      );
      return retryResponse.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  static Future<http.Response> _sendLogoutRequest({
    required String accessToken,
    http.Client? client,
  }) async {
    http.Client? ownedClient;

    try {
      final effectiveClient = client ?? (ownedClient = http.Client());
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/user/logout');
      return await effectiveClient
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      rethrow;
    } finally {
      ownedClient?.close();
    }
  }

  /// Clears the user created flag (useful on logout)
  static Future<void> clearUserCreatedFlag({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await TokenStorage.getUserId();
    if (effectiveUserId != null) {
      final userCreatedKey = '$_userCreatedFlagKey.$effectiveUserId';
      await prefs.remove(userCreatedKey);
    }
  }

  /// Deletes the currently signed-in user from backend.
  /// Uses the Cognito userId (sub) as path parameter.
  ///
  /// Returns true if the backend deletion succeeds.
  /// Treats an already-missing backend user as a successful delete so the
  /// Cognito deletion step can be safely retried.
  static Future<bool> deleteCurrentUserInBackend({http.Client? client}) async {
    http.Client? ownedClient;

    try {
      final effectiveClient = client ?? (ownedClient = http.Client());
      final userId = await TokenStorage.getUserId();
      if (userId == null || userId.trim().isEmpty) {
        return false;
      }

      final accessToken = await TokenStorage.getAccessToken();
      final idToken = await TokenStorage.getIdToken();
      if (accessToken == null ||
          accessToken.isEmpty ||
          idToken == null ||
          idToken.isEmpty) {
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'X-Id-Token': idToken,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/user/$userId');
      final response = await effectiveClient
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404;
    } catch (_) {
      return false;
    } finally {
      ownedClient?.close();
    }
  }
}
