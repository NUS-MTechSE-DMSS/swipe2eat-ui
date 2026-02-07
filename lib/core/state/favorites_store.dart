import 'package:flutter/material.dart';

import '../../models/food_item.dart';

class FavoritesStore {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  // Using ValueNotifier so UI can listen and rebuild
  final favorites = ValueNotifier<List<FoodItem>>([]);

  void add(FoodItem item) {
    final list = List<FoodItem>.from(favorites.value);
    if (list.any((x) => x.id == item.id)) return;
    list.insert(0, item);
    favorites.value = list;
  }

  void removeById(String id) {
    final list = List<FoodItem>.from(favorites.value);
    list.removeWhere((x) => x.id == id);
    favorites.value = list;
  }

  bool contains(String id) {
    return favorites.value.any((x) => x.id == id);
  }

  void clear() {
    favorites.value = [];
  }
}
