enum MessageSender { user, bot }

class FoodRecommendation {
  final String name;
  final double price;
  final int spiceLevel;
  final String cuisine;
  final List<String> reasons;

  const FoodRecommendation({
    required this.name,
    required this.price,
    required this.spiceLevel,
    required this.cuisine,
    required this.reasons,
  });

  factory FoodRecommendation.fromJson(Map<String, dynamic> json) {
    return FoodRecommendation(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      spiceLevel: (json['spice_level'] as num?)?.toInt() ?? 0,
      cuisine: json['cuisine']?.toString() ?? '',
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}

class ChatMessage {
  final MessageSender sender;
  final String text;
  final List<FoodRecommendation> recommendations;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    this.recommendations = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
