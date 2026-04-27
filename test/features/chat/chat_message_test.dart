import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/chat/models/chat_message.dart';

void main() {
  group('FoodRecommendation', () {
    test('parses response JSON and applies defaults', () {
      final recommendation = FoodRecommendation.fromJson({
        'name': 'Laksa',
        'price': 8.9,
        'spice_level': 3,
        'cuisine': 'Malay',
        'reasons': ['Spicy', 'Popular'],
      });

      expect(recommendation.name, 'Laksa');
      expect(recommendation.price, 8.9);
      expect(recommendation.spiceLevel, 3);
      expect(recommendation.cuisine, 'Malay');
      expect(recommendation.reasons, equals(['Spicy', 'Popular']));
    });

    test('falls back when optional values are missing', () {
      final recommendation = FoodRecommendation.fromJson(const {});

      expect(recommendation.name, isEmpty);
      expect(recommendation.price, 0);
      expect(recommendation.spiceLevel, 0);
      expect(recommendation.cuisine, isEmpty);
      expect(recommendation.reasons, isEmpty);
    });
  });

  group('ChatMessage', () {
    test('uses provided values and generated timestamp fallback', () {
      final before = DateTime.now();
      final message = ChatMessage(sender: MessageSender.bot, text: 'Hello');
      final after = DateTime.now();

      expect(message.sender, MessageSender.bot);
      expect(message.text, 'Hello');
      expect(message.recommendations, isEmpty);
      expect(
        message.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        message.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('preserves explicit timestamp and recommendations', () {
      final timestamp = DateTime(2024, 1, 1, 12);
      final recommendation = FoodRecommendation.fromJson({
        'name': 'Laksa',
        'price': 8.9,
        'spice_level': 3,
        'cuisine': 'Malay',
        'reasons': ['Spicy'],
      });

      final message = ChatMessage(
        sender: MessageSender.user,
        text: 'Suggest something spicy',
        recommendations: [recommendation],
        timestamp: timestamp,
      );

      expect(message.sender, MessageSender.user);
      expect(message.timestamp, timestamp);
      expect(message.recommendations.single.name, 'Laksa');
    });
  });
}
