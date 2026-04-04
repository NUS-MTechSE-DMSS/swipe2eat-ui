import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'dart:io';
import '../../test_helpers/network_image_stub.dart';

void main() {
  group('FavoritesScreen widget tests', () {
    setUp(() {
      FavoritesStore.instance.clear();
    });

    setUpAll(() {
      // Override HTTP requests for NetworkImage to return a tiny PNG
      HttpOverrides.global = TestHttpOverrides();
    });

    tearDownAll(() {
      HttpOverrides.global = null;
    });
  });
}

// Using shared TestHttpOverrides from test_helpers/network_image_stub.dart
