import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/cuisine_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';

class Swipe2EatApp extends StatelessWidget {
  const Swipe2EatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: '/sign-in',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/sign-in': (_) => SignInScreen(),
        '/sign-up': (_) => SignUpScreen(),
        '/cuisine': (_) => const CuisineScreen(),
      },
    );
  }
}
