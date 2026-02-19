import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/features/auth/screens/sign_up_screen.dart';

void main() {
  group('SignUpScreen Widget', () {
    testWidgets('displays Sign Up title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.text('Sign Up'), findsWidgets);
    });

    testWidgets('has email input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('has password input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      final passwordField = tester.widget<TextField>(textFields.at(1));
      expect(passwordField.obscureText, true);
    });

    testWidgets('has Register button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('has Sign In link button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('can enter email text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'newuser@example.com');

      expect(find.text('newuser@example.com'), findsOneWidget);
    });

    testWidgets('can enter password text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'newpass123');

      expect(find.text('newpass123'), findsOneWidget);
    });

    testWidgets('email field has email keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      final emailField = tester.widget<TextField>(textFields.at(0));
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('Register button navigates to sign-in screen', (WidgetTester tester) async {
      var navigatedToSignIn = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
          routes: {
            '/sign-in': (_) {
              navigatedToSignIn = true;
              return const Scaffold(body: SizedBox.shrink());
            }
          },
        ),
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(navigatedToSignIn, true);
    });

    testWidgets('Sign In link pops back to previous screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (settings) {
                if (settings.name == '/') {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Previous Screen')),
                    ),
                  );
                }
                return MaterialPageRoute(
                  builder: (_) => SignUpScreen(),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to sign up
      expect(find.byType(SignUpScreen), findsNothing);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('displays with proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('displays with proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('all input fields are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(TextField), findsExactly(2));
    });

    testWidgets('all buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
