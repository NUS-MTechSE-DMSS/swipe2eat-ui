import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveLocalPreferences stores cuisines and budget', () async {
      await PreferencesService.saveLocalPreferences(
        cuisines: ['Thai', 'Japanese', 'Indian'],
        budget: 'medium',
      );

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('prefs.cuisines') ?? [];
      final budgetStored = prefs.getString('prefs.budget');

      expect(stored, equals(['Thai', 'Japanese', 'Indian']));
      expect(budgetStored, equals('medium'));
    });

    test('getLocalPreferences returns saved preferences', () async {
      await PreferencesService.saveLocalPreferences(
        cuisines: ['Chinese', 'Western'],
        budget: 'low',
      );

      final prefs = await PreferencesService.getLocalPreferences();

      expect(prefs['cuisines'], equals(['Chinese', 'Western']));
      expect(prefs['budget'], equals('low'));
    });

    test(
      'getLocalPreferences returns defaults when no preferences stored',
      () async {
        final prefs = await PreferencesService.getLocalPreferences();

        expect(prefs['cuisines'], equals(['Chinese', 'Thai', 'Western']));
        expect(prefs['budget'], equals('low'));
        expect(prefs['spiceLevel'], equals('Medium'));
      },
    );

    test(
      'preferencesUpdated notifier increments when preferences change',
      () async {
        int notificationCount = 0;
        PreferencesService.preferencesUpdated.addListener(() {
          notificationCount++;
        });

        await PreferencesService.saveLocalPreferences(
          cuisines: ['Thai'],
          budget: 'high',
        );

        expect(notificationCount, greaterThan(0));

        PreferencesService.preferencesUpdated.removeListener(() {});
      },
    );

    test('saveLocalPreferences with empty cuisines', () async {
      await PreferencesService.saveLocalPreferences(
        cuisines: [],
        budget: 'low',
      );

      final prefs = await PreferencesService.getLocalPreferences();
      expect(prefs['cuisines'], isEmpty);
    });

    test('saveLocalPreferences updates existing preferences', () async {
      // First save
      await PreferencesService.saveLocalPreferences(
        cuisines: ['Thai'],
        budget: 'low',
      );

      // Second save (update)
      await PreferencesService.saveLocalPreferences(
        cuisines: ['Japanese', 'Indian'],
        budget: 'high',
      );

      final prefs = await PreferencesService.getLocalPreferences();
      expect(prefs['cuisines'], equals(['Japanese', 'Indian']));
      expect(prefs['budget'], equals('high'));
    });

    test('budget values map correctly', () async {
      final budgetTests = [
        ('low', 'low'),
        ('medium', 'medium'),
        ('high', 'high'),
      ];

      for (final (input, expected) in budgetTests) {
        SharedPreferences.setMockInitialValues({});
        await PreferencesService.saveLocalPreferences(
          cuisines: ['Thai'],
          budget: input,
        );

        final prefs = await PreferencesService.getLocalPreferences();
        expect(prefs['budget'], equals(expected));
      }
    });

    test('multiple cuisine selections are preserved', () async {
      const cuisines = [
        'Thai',
        'Chinese',
        'Japanese',
        'Italian',
        'Indian',
        'Vietnamese',
      ];

      await PreferencesService.saveLocalPreferences(
        cuisines: cuisines,
        budget: 'medium',
      );

      final prefs = await PreferencesService.getLocalPreferences();
      expect(prefs['cuisines'], equals(cuisines));
    });

    test('saveLocalPreferences stores normalized spice level', () async {
      await PreferencesService.saveLocalPreferences(
        cuisines: ['Thai'],
        budget: 'medium',
        spiceLevel: 'hot',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('prefs.spice'), equals('Hot'));
    });

    test(
      'saveLocalPreferences does not overwrite spice when omitted',
      () async {
        await PreferencesService.saveLocalPreferences(
          cuisines: ['Thai'],
          budget: 'low',
          spiceLevel: 'mild',
        );
        await PreferencesService.saveLocalPreferences(
          cuisines: ['Japanese'],
          budget: 'high',
        );

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('prefs.spice'), equals('Mild'));
      },
    );
  });
}
