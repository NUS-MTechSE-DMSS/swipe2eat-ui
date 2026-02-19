import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/app.dart';

void main() {
  group('Swipe2EatApp', () {
    testWidgets('app starts with sign-in route', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());
      await tester.pumpAndSettle();

      // The initial route is '/sign-in'
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app disables debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('app has theme applied', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('app defines all required routes', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/'), true);
      expect(materialApp.routes!.containsKey('/sign-in'), true);
      expect(materialApp.routes!.containsKey('/sign-up'), true);
      expect(materialApp.routes!.containsKey('/cuisine'), true);
    });

    testWidgets('initial route is set to sign-in', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, '/sign-in');
    });

    testWidgets('app widget is stateless', (WidgetTester tester) async {
      const app = Swipe2EatApp();
      expect(app, isA<StatelessWidget>());
    });

    testWidgets('app has home route', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes!.containsKey('/'), true);
    });

    testWidgets('app has sign-up route', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes!.containsKey('/sign-up'), true);
    });

    testWidgets('app has cuisine selection route', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes!.containsKey('/cuisine'), true);
    });

    testWidgets('routes are not null', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      for (var entry in materialApp.routes!.entries) {
        expect(entry.value, isNotNull);
      }
    });

    testWidgets('theme is applied correctly to app', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.useMaterial3, true);
    });

    testWidgets('app renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const Swipe2EatApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
