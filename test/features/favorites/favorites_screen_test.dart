import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/favorites/favorites_screen.dart';
import 'package:swipe2eat_ui/core/state/favorites_store.dart';
import 'package:swipe2eat_ui/models/food_item.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
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

    Widget makeTestable({required Widget child}) {
      return MaterialApp(home: Scaffold(body: child));
    }  });
}

// Using shared TestHttpOverrides from test_helpers/network_image_stub.dart
