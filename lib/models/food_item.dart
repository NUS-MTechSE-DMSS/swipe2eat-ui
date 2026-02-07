class FoodItem {
  final String id;
  final String name;
  final String restaurant;
  final String imageUrl;
  final double rating;
  final double price;
  final String distanceLabel; // e.g. "0.7 mi away"
  final int spiceLevel; // 1..3
  final int budgetLevel; // 1..3
  final List<String> tags;

  FoodItem({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.distanceLabel,
    required this.spiceLevel,
    required this.budgetLevel,
    required this.tags,
  });
}
