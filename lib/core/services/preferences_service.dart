import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/token_storage.dart';

class PreferencesService {
  static const String _baseUrl =
      'http://swe5006-nus-g3-alb-dev-1647279843.ap-southeast-1.elb.amazonaws.com';
  static const String _prefsTempUserIdKey = 'prefs.tempUserId';
  static const String _prefsCuisinesKey = 'prefs.cuisines';
  static const String _prefsBudgetKey = 'prefs.budget';

  /// ValueNotifier that emits when preferences are updated
  /// Subscribers (like DiscoverScreen) can listen to this to refresh their data
  static final preferencesUpdated = ValueNotifier<int>(0);

  /// Builds HTTP headers with AWS Cognito authentication.
  /// Includes the ID token from Cognito for backend API authorization
  static Future<Map<String, String>> _buildAuthHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add Cognito ID token if available
    final authHeader = await TokenStorage.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }

    return headers;
  }

  /// Gets the temporary user id from local storage
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsTempUserIdKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }
    const fallback = '22222222-2222-2222-2222-222222222222';
    await prefs.setString(_prefsTempUserIdKey, fallback);
    return fallback;
  }

  /// Updates preferences on the backend (cuisines and budget)
  /// Returns true if successful, false otherwise
  static Future<bool> updatePreferences({
    required List<String> cuisines,
    required String budget,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.trim().isEmpty) {
        return false;
      }

      final uri = Uri.parse('$_baseUrl/preference/users/$userId');
      final headers = await _buildAuthHeaders();
      final payload = jsonEncode({
        'cuisines': cuisines,
        'budget': budget,
      });

      final res = await http.put(uri, headers: headers, body: payload);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Gets current preferences from local storage
  static Future<Map<String, dynamic>> getLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cuisines = prefs.getStringList(_prefsCuisinesKey) ?? ['Chinese', 'Thai', 'Western'];
    final budget = prefs.getString(_prefsBudgetKey) ?? 'low';

    return {
      'cuisines': cuisines,
      'budget': budget,
    };
  }

  /// Saves preferences to local storage and notifies listeners
  static Future<void> saveLocalPreferences({
    required List<String> cuisines,
    required String budget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsCuisinesKey, cuisines);
    await prefs.setString(_prefsBudgetKey, budget);
    
    // Notify listeners that preferences have been updated
    preferencesUpdated.value++;
  }

  /// Fetches preferences from backend and saves them locally
  /// Returns the fetched preferences map if successful
  static Future<Map<String, dynamic>?> fetchPreferencesFromBackend() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.trim().isEmpty) {
        return null;
      }

      final uri = Uri.parse('$_baseUrl/preference/users/$userId');
      final res = await http.get(uri, headers: await _buildAuthHeaders());

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        
        // Extract cuisines (handle both string and array formats)
        List<String> cuisines = [];
        final cuisinesData = json['cuisines'];
        if (cuisinesData is List) {
          cuisines = List<String>.from(cuisinesData);
        } else if (cuisinesData is String) {
          cuisines = [cuisinesData];
        }

        // Extract budget
        final budget = json['budget']?.toString() ?? 'low';

        // Save to local storage
        await saveLocalPreferences(cuisines: cuisines, budget: budget);

        return {
          'cuisines': cuisines,
          'budget': budget,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
