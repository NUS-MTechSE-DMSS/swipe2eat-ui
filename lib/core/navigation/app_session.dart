import 'package:flutter/material.dart';

class AppSession {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSessionExpired() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil('/sign-in', (route) => false);
      }

      scaffoldMessengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Your session expired. Please sign in again.'),
          ),
        );
    });
  }
}
