import 'dart:async';

import 'package:flutter/material.dart';
import 'core/navigation/main_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/services/preferences_service.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/cuisine_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/services/token_storage.dart';

class Swipe2EatApp extends StatelessWidget {
  const Swipe2EatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: '/launch',
      routes: {
        '/launch': (_) => const _AuthGate(),
        '/': (_) => const _AuthenticatedOnly(child: WelcomeScreen()),
        '/sign-in': (_) => const SignInScreen(),
        '/sign-up': (_) => const SignUpScreen(),
        '/cuisine': (_) => const _AuthenticatedOnly(child: CuisineScreen()),
        '/main': (_) => const _AuthenticatedOnly(
              child: MainShell(initialTab: MainTab.discover),
            ),
      },
    );
  }
}

enum _StartupDestination { signIn, onboarding, main }

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<_StartupDestination> _destinationFuture =
      _resolveDestination();

  Future<_StartupDestination> _resolveDestination() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) {
      return _StartupDestination.signIn;
    }

    final hasPreferences = await PreferencesService.hasUserPreferences();
    if (hasPreferences) {
      unawaited(PreferencesService.fetchPreferencesFromBackend());
      return _StartupDestination.main;
    }

    return _StartupDestination.onboarding;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupDestination>(
      future: _destinationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LaunchLoadingScreen();
        }

        switch (snapshot.data) {
          case _StartupDestination.main:
            return const MainShell(initialTab: MainTab.discover);
          case _StartupDestination.onboarding:
            return const WelcomeScreen();
          case _StartupDestination.signIn:
          default:
            return const SignInScreen();
        }
      },
    );
  }
}

class _AuthenticatedOnly extends StatelessWidget {
  final Widget child;

  const _AuthenticatedOnly({required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenStorage.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LaunchLoadingScreen();
        }

        if (snapshot.data == true) {
          return child;
        }

        return const SignInScreen();
      },
    );
  }
}

class _LaunchLoadingScreen extends StatelessWidget {
  const _LaunchLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F1),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
