import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../features/auth/services/token_storage.dart';
import '../models/chat_message.dart';

class ChatService {
  static Future<Map<String, String>> _buildAuthHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final authHeader = await TokenStorage.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    return headers;
  }

  static Future<ChatMessage> sendMessage(String message) async {
    final userId = await TokenStorage.getUserId();
    if (userId == null || userId.trim().isEmpty) {
      return ChatMessage(
        sender: MessageSender.bot,
        text: 'Unable to send message: not logged in.',
      );
    }

    try {
      final uri = Uri.parse(ApiConfig.llmChatUrl);
      final headers = await _buildAuthHeaders();
      final body = jsonEncode({'message': message, 'user_id': userId});

      final res = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 90));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final reply = json['reply']?.toString() ?? 'No reply received.';
        final recs = (json['recommendations'] as List<dynamic>? ?? [])
            .map((r) => FoodRecommendation.fromJson(r as Map<String, dynamic>))
            .toList();
        return ChatMessage(
          sender: MessageSender.bot,
          text: reply,
          recommendations: recs,
        );
      }

      return ChatMessage(
        sender: MessageSender.bot,
        text: 'Something went wrong (${res.statusCode}). Please try again.',
      );
    } catch (_) {
      return ChatMessage(
        sender: MessageSender.bot,
        text: 'Could not reach the AI service. Please check your connection.',
      );
    }
  }
}
