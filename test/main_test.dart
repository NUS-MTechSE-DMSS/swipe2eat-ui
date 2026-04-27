import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:swipe2eat_ui/main.dart' as app;

void main() {
  testWidgets('main boots the application widget tree', (tester) async {
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
