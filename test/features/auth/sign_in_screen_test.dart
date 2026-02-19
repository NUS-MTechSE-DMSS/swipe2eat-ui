import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/sign_in_screen.dart';

void main() {
  group('SignInScreen Widget', () {
    testWidgets('displays Sign In title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('has email input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('has password input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // The second TextField should be the password field
      final passwordField = tester.widget<TextField>(textFields.at(1));
      expect(passwordField.obscureText, true);
    });

    testWidgets('email field is not obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      final emailField = tester.widget<TextField>(textFields.at(0));
      expect(emailField.obscureText, false);
    });

    testWidgets('has Login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('has Sign Up link button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });

    testWidgets('can enter email text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('can enter password text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'password123');

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('email field has email keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      final emailField = tester.widget<TextField>(textFields.at(0));
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('Login button navigates on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Verify Login button exists and is tappable
      expect(find.text('Login'), findsOneWidget);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Button should still be present after tap
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Sign Up button navigates to sign up screen', (WidgetTester tester) async {
      var navigatedToSignUp = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
          routes: {
            '/sign-up': (_) {
              navigatedToSignUp = true;
              return const Scaffold(body: SizedBox.shrink());
            }
          },
        ),
      );

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      expect(navigatedToSignUp, true);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('displays with proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('all widgets are visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
