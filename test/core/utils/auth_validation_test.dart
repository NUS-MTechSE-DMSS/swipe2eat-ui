import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Validation Tests', () {
    // Email validation
    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
      return null;
    }

    // Password validation
    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    }

    // Confirm password validation
    String? validateConfirmPassword(String? value, String password) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    }

    group('Email Validation', () {
      test('null email returns error', () {
        expect(validateEmail(null), equals('Email is required'));
      });

      test('empty email returns error', () {
        expect(validateEmail(''), equals('Email is required'));
      });

      test('valid email returns null', () {
        expect(validateEmail('user@example.com'), isNull);
      });

      test('email without @ returns error', () {
        expect(
          validateEmail('userexample.com'),
          equals('Please enter a valid email'),
        );
      });

      test('email without domain returns error', () {
        expect(validateEmail('user@'), equals('Please enter a valid email'));
      });

      test('email without TLD returns error', () {
        expect(
          validateEmail('user@example'),
          equals('Please enter a valid email'),
        );
      });

      test('valid email with numbers and special chars', () {
        expect(validateEmail('user123+tag@example.co.uk'), isNull);
      });

      test('uppercase email returns null (case insensitive)', () {
        expect(validateEmail('USER@EXAMPLE.COM'), isNull);
      });

      test('email with dots in local part', () {
        expect(validateEmail('user.name@example.com'), isNull);
      });

      test('email with hyphen in domain', () {
        expect(validateEmail('user@my-example.com'), isNull);
      });
    });

    group('Password Validation', () {
      test('null password returns error', () {
        expect(validatePassword(null), equals('Password is required'));
      });

      test('empty password returns error', () {
        expect(validatePassword(''), equals('Password is required'));
      });

      test('password less than 6 chars returns error', () {
        expect(
          validatePassword('pass'),
          equals('Password must be at least 6 characters'),
        );
      });

      test('password with exactly 6 chars is valid', () {
        expect(validatePassword('123456'), isNull);
      });

      test('password with more than 6 chars is valid', () {
        expect(validatePassword('MyPassword123'), isNull);
      });

      test('password with special characters is valid', () {
        expect(validatePassword('Pass@123!'), isNull);
      });

      test('password with spaces is valid', () {
        expect(validatePassword('pass word'), isNull);
      });

      test('password with 5 chars returns error', () {
        expect(
          validatePassword('12345'),
          equals('Password must be at least 6 characters'),
        );
      });
    });

    group('Confirm Password Validation', () {
      test('null confirm password returns error', () {
        expect(
          validateConfirmPassword(null, 'password123'),
          equals('Please confirm your password'),
        );
      });

      test('empty confirm password returns error', () {
        expect(
          validateConfirmPassword('', 'password123'),
          equals('Please confirm your password'),
        );
      });

      test('passwords match returns null', () {
        expect(validateConfirmPassword('password123', 'password123'), isNull);
      });

      test('passwords do not match returns error', () {
        expect(
          validateConfirmPassword('password123', 'password456'),
          equals('Passwords do not match'),
        );
      });

      test('case sensitive password comparison', () {
        expect(
          validateConfirmPassword('Password', 'password'),
          equals('Passwords do not match'),
        );
      });

      test('matching complex passwords', () {
        final pw = 'MyPass@123!';
        expect(validateConfirmPassword(pw, pw), isNull);
      });

      test('empty password and confirmation returns error', () {
        expect(
          validateConfirmPassword('', ''),
          equals('Please confirm your password'),
        );
      });
    });

    group('Combined Validation Flow', () {
      test('valid sign up credentials', () {
        final email = 'user@example.com';
        final password = 'StrongPass123';
        final confirm = 'StrongPass123';

        expect(validateEmail(email), isNull);
        expect(validatePassword(password), isNull);
        expect(validateConfirmPassword(confirm, password), isNull);
      });

      test('invalid email with valid passwords', () {
        final email = 'invalid.email';
        final password = 'StrongPass123';
        final confirm = 'StrongPass123';

        expect(validateEmail(email), isNotNull);
        expect(validatePassword(password), isNull);
        expect(validateConfirmPassword(confirm, password), isNull);
      });

      test('valid email with weak password', () {
        final email = 'user@example.com';
        final password = 'weak';
        final confirm = 'weak';

        expect(validateEmail(email), isNull);
        expect(validatePassword(password), isNotNull);
        expect(validateConfirmPassword(confirm, password), isNull);
      });

      test('valid email and password with mismatched confirmation', () {
        final email = 'user@example.com';
        final password = 'StrongPass123';
        final confirm = 'DifferentPass123';

        expect(validateEmail(email), isNull);
        expect(validatePassword(password), isNull);
        expect(validateConfirmPassword(confirm, password), isNotNull);
      });
    });
  });
}
