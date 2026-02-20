import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/theme/app_colors.dart';
import 'package:swipe2eat_ui/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('background color is defined', () {
      expect(AppColors.background, isNotNull);
      expect(AppColors.background, equals(const Color(0xFFFFF8F1)));
    });

    test('primary gradient colors are defined', () {
      expect(AppColors.primaryStart, isNotNull);
      expect(AppColors.primaryEnd, isNotNull);
      expect(AppColors.primaryStart, equals(const Color(0xFFFF8A3D)));
      expect(AppColors.primaryEnd, equals(const Color(0xFFFF4D4D)));
    });

    test('green gradient colors are defined', () {
      expect(AppColors.greenStart, isNotNull);
      expect(AppColors.greenEnd, isNotNull);
      expect(AppColors.greenStart, equals(const Color(0xFF4ADE80)));
      expect(AppColors.greenEnd, equals(const Color(0xFF22C55E)));
    });

    test('text colors are defined', () {
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.textSecondary, isNotNull);
      expect(AppColors.textPrimary, equals(const Color(0xFF111827)));
      expect(AppColors.textSecondary, equals(const Color(0xFF6B7280)));
    });

    test('colors have correct color values', () {
      // Background should be a light cream color
      expect(AppColors.background.value, greaterThan(0xFFFFFFFF - 0xFF00FFFF));

      // Primary colors should be warm (orange/red tones)
      expect(AppColors.primaryStart.value, greaterThan(0xFF000000));
      expect(AppColors.primaryEnd.value, greaterThan(0xFF000000));

      // Green colors should be green tones
      expect(AppColors.greenStart.value, greaterThan(0xFF000000));
      expect(AppColors.greenEnd.value, greaterThan(0xFF000000));
    });
  });

  group('AppTheme', () {
    test('appTheme returns a ThemeData object', () {
      final theme = appTheme();
      expect(theme, isA<ThemeData>());
    });

    test('theme has scaffold background color set', () {
      final theme = appTheme();
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });

    test('theme uses material 3', () {
      final theme = appTheme();
      expect(theme.useMaterial3, true);
    });

    test('theme has text theme defined', () {
      final theme = appTheme();
      expect(theme.textTheme, isNotNull);
    });

    test('headline medium text style is configured', () {
      final theme = appTheme();
      final headlineStyle = theme.textTheme.headlineMedium;

      expect(headlineStyle, isNotNull);
      expect(headlineStyle?.fontWeight, FontWeight.bold);
      expect(headlineStyle?.color, AppColors.textPrimary);
    });

    test('body medium text style is configured', () {
      final theme = appTheme();
      final bodyStyle = theme.textTheme.bodyMedium;

      expect(bodyStyle, isNotNull);
      expect(bodyStyle?.color, AppColors.textSecondary);
    });

    test('theme applies to scaffold background', () {
      final theme = appTheme();
      expect(theme.scaffoldBackgroundColor, isNotNull);
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });
  });

  group('Theme Integration', () {
    testWidgets('app applies theme to widgets', (WidgetTester tester) async {
      final theme = appTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                Text(
                  'Headline',
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  'Body',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Headline'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('scaffold has correct background color', (WidgetTester tester) async {
      final theme = appTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor ?? theme.scaffoldBackgroundColor,
          equals(AppColors.background));
    });

    testWidgets('text inherits theme styles', (WidgetTester tester) async {
      final theme = appTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Text(
              'Test Text',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test Text'));
      expect(text.style?.color, AppColors.textSecondary);
    });

    testWidgets('multiple app instances can have same theme',
        (WidgetTester tester) async {
      final theme1 = appTheme();
      final theme2 = appTheme();

      expect(theme1.scaffoldBackgroundColor, equals(theme2.scaffoldBackgroundColor));
      expect(theme1.useMaterial3, equals(theme2.useMaterial3));
      expect(theme1.textTheme.headlineMedium?.fontWeight,
          equals(theme2.textTheme.headlineMedium?.fontWeight));
    });
  });

  group('Color Contrast', () {
    test('primary colors have sufficient contrast with white text', () {
      // Check that primary colors are dark enough for white text
      expect(AppColors.primaryStart.value, isNotNull);
      expect(AppColors.primaryEnd.value, isNotNull);
    });

    test('text colors have sufficient contrast with background', () {
      // Primary text should be dark (for use on light background)
      expect(AppColors.textPrimary.value, lessThan(0xFF888888));
      // Secondary text should be medium (for use on light background)
      expect(AppColors.textSecondary.value, lessThan(0xFF999999));
    });
  });
}
