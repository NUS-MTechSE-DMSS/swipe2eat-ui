class FoodItem {
  final String id;
  final String name;
  final String restaurant;
  final String imageUrl;
  final double rating;
  final double price;
  final String description;
  final String distanceLabel; // e.g. "0.7 mi away"
  final int spiceLevel; // low, medium, high
  final int budgetLevel; // low, medium, high
  final List<String> tags;

  FoodItem({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.description,
    required this.distanceLabel,
    required this.spiceLevel,
    required this.budgetLevel,
    required this.tags,
  });
}
