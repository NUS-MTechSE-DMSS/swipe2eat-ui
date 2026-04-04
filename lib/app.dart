import 'dart:async';

import 'package:flutter/material.dart';
import 'core/navigation/main_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/services/preferences_service.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/cuisine_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
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
        '/forgot-password': (_) => const ForgotPasswordScreen(),
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
  @override
  void initState() {
    super.initState();
    unawaited(_redirectToStartupDestination());
  }

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

  Future<void> _redirectToStartupDestination() async {
    final destination = await _resolveDestination();
    if (!mounted) return;

    final routeName = switch (destination) {
      _StartupDestination.main => '/main',
      _StartupDestination.onboarding => '/',
      _StartupDestination.signIn => '/sign-in',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _LaunchLoadingScreen();
  }
}

class _AuthenticatedOnly extends StatefulWidget {
  final Widget child;

  const _AuthenticatedOnly({required this.child});

  @override
  State<_AuthenticatedOnly> createState() => _AuthenticatedOnlyState();
}

class _AuthenticatedOnlyState extends State<_AuthenticatedOnly> {
  late final Future<bool> _isLoggedInFuture = TokenStorage.isLoggedIn();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LaunchLoadingScreen();
        }

        if (snapshot.data == true) {
          return widget.child;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/sign-in', (route) => false);
        });

        return const _LaunchLoadingScreen();
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
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
