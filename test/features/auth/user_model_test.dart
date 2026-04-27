import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('parses optional fields from JSON', () {
      final user = UserModel.fromJson({
        'id': 'user-123',
        'email': 'user@example.com',
        'name': 'Jane Doe',
        'gender': 'female',
        'dateOfBirth': '1995-04-12',
      });

      expect(user.id, 'user-123');
      expect(user.email, 'user@example.com');
      expect(user.name, 'Jane Doe');
      expect(user.gender, 'female');
      expect(user.dateOfBirth, DateTime(1995, 4, 12));
    });

    test('serializes values back to JSON and tolerates invalid dates', () {
      final invalidDateUser = UserModel.fromJson({
        'id': 'user-123',
        'email': 'user@example.com',
        'dateOfBirth': 'not-a-date',
      });

      expect(invalidDateUser.dateOfBirth, isNull);

      final user = UserModel(
        id: 'user-123',
        email: 'user@example.com',
        name: 'Jane Doe',
        gender: 'female',
        dateOfBirth: DateTime(1995, 4, 12),
      );

      expect(
        user.toJson(),
        equals({
          'id': 'user-123',
          'email': 'user@example.com',
          'name': 'Jane Doe',
          'gender': 'female',
          'dateOfBirth': '1995-04-12',
        }),
      );
    });
  });
}
