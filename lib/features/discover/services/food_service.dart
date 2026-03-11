import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../models/food_item.dart';
import '../../../core/config/api_config.dart';
import '../../auth/services/token_storage.dart';

/// Service for food-related API operations.
/// Handles fetching foods from the backend.
class FoodService {
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  static int _invalidFoodIdDropCount = 0;
  static int _lastInvalidFoodIdDropCount = 0;

  /// Total number of food records dropped due to missing/invalid UUID IDs
  /// since app start.
  static int get invalidFoodIdDropCount => _invalidFoodIdDropCount;
  static int get lastInvalidFoodIdDropCount => _lastInvalidFoodIdDropCount;

  /// Builds HTTP headers with AWS Cognito authentication.
  /// Retrieves the ID token from TokenStorage and includes it in the Authorization header.
  static Future<Map<String, String>> _buildAuthHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final authHeader = await TokenStorage.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    return headers;
  }

  /// Converts spice level string to numeric value for API.
  /// 1 = mild, 2 = medium, 3 = hot
  static int _spiceLevelToNumber(String spiceLevel) {
    switch (spiceLevel.toLowerCase().trim()) {
      case 'mild':
        return 1;
      case 'medium':
        return 2;
      case 'hot':
        return 3;
      default:
        return 2; // default to medium
    }
  }

  /// Fetches foods from the backend based on user preferences.
  ///
  /// Parameters:
  /// - [cuisines]: List of preferred cuisines
  /// - [budget]: Budget level ('low', 'medium', 'high')
  /// - [spiceLevel]: Spice preference ('mild', 'medium', 'hot')
  /// - [dietType]: Dietary type (optional, use 'None' to exclude)
  /// - [allergens]: List of allergens to avoid
  ///
  /// Returns a list of [FoodItem] objects or throws an exception on failure.
  static Future<List<FoodItem>> fetchFoods({
    required List<String> cuisines,
    required String budget,
    required String spiceLevel,
    String? dietType,
    List<String>? allergens,
  }) async {
    final baseUri = Uri.parse('${ApiConfig.baseUrl}/food');

    final params = <String>['budget=${Uri.encodeQueryComponent(budget)}'];

    if (cuisines.isNotEmpty) {
      params.addAll(
        cuisines.map((c) => 'cuisines=${Uri.encodeQueryComponent(c)}'),
      );
    }

    if (spiceLevel.trim().isNotEmpty) {
      final spiceNum = _spiceLevelToNumber(spiceLevel);
      params.add('spiceLevel=$spiceNum');
    }

    if (dietType != null && dietType.trim().isNotEmpty && dietType != 'None') {
      params.add('dietType=${Uri.encodeQueryComponent(dietType)}');
    }

    if (allergens != null && allergens.isNotEmpty) {
      params.addAll(
        allergens.map((a) => 'allergens=${Uri.encodeQueryComponent(a)}'),
      );
    }

    final query = params.join('&');
    final uri = baseUri.replace(query: query);
    final headers = await _buildAuthHeaders();

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load foods (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    final list = _extractList(data);
    final foods = <FoodItem>[];
    final droppedIdSamples = <String>[];
    var droppedInThisFetch = 0;
    _lastInvalidFoodIdDropCount = 0;

    for (final raw in list) {
      final rawId = _extractRawId(raw);
      if (rawId == null || !_isValidUuid(rawId)) {
        droppedInThisFetch++;
        if (droppedIdSamples.length < 5) {
          droppedIdSamples.add(rawId ?? '<missing>');
        }
        continue;
      }

      final item = _foodFromJson(raw);
      if (item != null) {
        foods.add(item);
      }
    }

    if (droppedInThisFetch > 0) {
      _lastInvalidFoodIdDropCount = droppedInThisFetch;
      _invalidFoodIdDropCount += droppedInThisFetch;
      developer.log(
        'Dropped $droppedInThisFetch food records with invalid UUID ids. '
        'Sample ids: ${droppedIdSamples.join(", ")}. '
        'Total dropped since app start: $_invalidFoodIdDropCount.',
        name: 'FoodService',
        level: 900,
      );
    }

    return foods;
  }

  /// Extracts the list of food items from various response formats.
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is Map && data['foods'] is List) return data['foods'] as List;
    return const <dynamic>[];
  }

  /// Parses a JSON object into a [FoodItem].
  static FoodItem? _foodFromJson(dynamic raw) {
    if (raw is! Map) return null;

    String? readString(String key) {
      final v = raw[key];
      return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
    }

    double readDouble(String key, {double fallback = 0}) {
      final v = raw[key];
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final id = readString('id');
    if (id == null || !_isValidUuid(id)) {
      return null;
    }
    final name = readString('name') ?? "Unknown Dish";
    final restaurant = readString('restaurantName') ?? "Unknown";
    final rating = readDouble('rating', fallback: 4.5);
    final price = readDouble('price', fallback: 14.99);
    final description =
        readString('description') ??
        "A delicious pick based on your preferences.";

    final imageKey = readString('imageKey');
    final imageUrl =
        _imageUrlFromKey(imageKey) ??
        "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1200";

    const int spiceLevel = 2;

    int budgetLevel;
    if (price <= 10) {
      budgetLevel = 1;
    } else if (price <= 20) {
      budgetLevel = 2;
    } else {
      budgetLevel = 3;
    }

    List<String> tags = const [];
    final cuisineRaw = raw['cuisine'];
    if (cuisineRaw is List) {
      tags = cuisineRaw.map((e) => e.toString()).toList();
    }

    return FoodItem(
      id: id,
      name: name,
      restaurant: restaurant,
      imageUrl: imageUrl,
      rating: rating,
      price: price,
      description: description,
      distanceLabel: '',
      spiceLevel: spiceLevel,
      budgetLevel: budgetLevel,
      tags: tags,
    );
  }

  static bool _isValidUuid(String value) {
    return _uuidPattern.hasMatch(value);
  }

  static String? _extractRawId(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id.trim();
    }
    return null;
  }

  /// Converts an image key to a full URL.
  /// If the key is already a URL, returns it as-is.
  /// Otherwise, constructs an S3 bucket URL.
  static String? _imageUrlFromKey(String? imageKey) {
    if (imageKey == null || imageKey.trim().isEmpty) return null;
    final key = imageKey.trim();
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    // Append to S3 bucket URL
    return 'https://swe5006-nus-g3-public-dev-ap-southeast-1-282793424364.s3.ap-southeast-1.amazonaws.com/images/$key';
  }
}
