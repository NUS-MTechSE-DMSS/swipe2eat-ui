import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/services/token_storage.dart';
import '../models/dietary_options.dart';

class DietaryService {
  // currently using a dedicated dietary service endpoint; replace with AWS endpoint later
  static const String _baseUrl = 'http://54.255.48.54:8080/dietary';

  /// Builds HTTP headers with AWS Cognito authentication.
  static Future<Map<String, String>> _buildAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final authHeader = await TokenStorage.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }

    return headers;
  }

  /// Fetches dietary options from backend.
  static Future<DietaryOptions> fetchOptions() async {
    final uri = Uri.parse('$_baseUrl/options');
    final res = await http.get(
      uri,
      headers: await _buildAuthHeaders(),
    ).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200) {
      throw Exception('Failed to load options (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return DietaryOptions.fromJson(data);
  }
}
