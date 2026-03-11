class DietaryOptions {
  final List<String> dietType;
  final List<String> allergens;

  const DietaryOptions({
    required this.dietType,
    required this.allergens,
  });

  factory DietaryOptions.fromJson(Map<String, dynamic> json) {
    return DietaryOptions(
      dietType: List<String>.from(json['dietType'] ?? const []),
      allergens: List<String>.from(json['allergens'] ?? const []),
    );
  }

  // Fallback data when API is unavailable.
  static const DietaryOptions fallback = DietaryOptions(
    dietType: [
      'Omnivore',
      'Vegetarian',
      'Vegan',
      'Halal',
      'Kosher',
    ],
    allergens: [
      'Peanut',
      'Dairy',
      'Gluten',
      'Shellfish',
      'Soy',
      'Sesame',
      'Tree Nuts',
    ],
  );
}
