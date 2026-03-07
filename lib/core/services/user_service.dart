import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/token_storage.dart';

/// Service for managing user operations with the backend
class UserService {
  static const String _baseUrl =
      'http://swe5006-nus-g3-alb-dev-1647279843.ap-southeast-1.elb.amazonaws.com';
  
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

      // Get ID token for backend authentication
      final idToken = await TokenStorage.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return false;
      }

      // Build headers with Authorization header for backend authentication
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      // Call backend to create user
      final uri = Uri.parse('$_baseUrl/user/create-user');
      final response = await http.post(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
      );

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

  /// Clears the user created flag (useful on logout)
  static Future<void> clearUserCreatedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      final userCreatedKey = '$_userCreatedFlagKey.$userId';
      await prefs.remove(userCreatedKey);
    }
  }
}
