// Auth routes
import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';

class AuthRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/sign-in': (context) => SignInScreen(),
        '/sign-up': (context) => SignUpScreen(),
        '/splash': (context) => SplashScreen(),
      };
}
