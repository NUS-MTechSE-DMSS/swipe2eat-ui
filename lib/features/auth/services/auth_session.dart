import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/navigation/app_session.dart';
import 'cognito_service.dart';
import 'token_storage.dart';

class AuthSession {
  static const Duration refreshBuffer = Duration(minutes: 5);
  static Future<bool>? _pendingRefresh;

  static Future<bool> ensureFreshSession({
    bool forceRefresh = false,
    http.Client? cognitoClient,
    bool redirectOnFailure = true,
  }) async {
    final idToken = await TokenStorage.getIdToken();
    final accessToken = await TokenStorage.getAccessToken();
    if (idToken == null ||
        idToken.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      if (redirectOnFailure) {
        await _expireSession();
      }
      return false;
    }

    if (!forceRefresh && !await _shouldRefresh(idToken, accessToken)) {
      return true;
    }

    return _refresh(
      cognitoClient: cognitoClient,
      redirectOnFailure: redirectOnFailure,
    );
  }

  static Future<bool> _shouldRefresh(String idToken, String accessToken) async {
    final now = DateTime.now();
    final idExpiresAt =
        await TokenStorage.getIdTokenExpiresAt() ??
        TokenStorage.extractExpiresAtFromToken(idToken);
    final accessExpiresAt =
        await TokenStorage.getAccessTokenExpiresAt() ??
        TokenStorage.extractExpiresAtFromToken(accessToken);

    if (idExpiresAt == null || accessExpiresAt == null) {
      return false;
    }

    return idExpiresAt.isBefore(now.add(refreshBuffer)) ||
        accessExpiresAt.isBefore(now.add(refreshBuffer));
  }

  static Future<bool> _refresh({
    http.Client? cognitoClient,
    required bool redirectOnFailure,
  }) {
    final pending = _pendingRefresh;
    if (pending != null) {
      return pending;
    }

    final refreshFuture = _performRefresh(
      cognitoClient: cognitoClient,
      redirectOnFailure: redirectOnFailure,
    );
    _pendingRefresh = refreshFuture;
    refreshFuture.whenComplete(() => _pendingRefresh = null);
    return refreshFuture;
  }

  static Future<bool> _performRefresh({
    http.Client? cognitoClient,
    required bool redirectOnFailure,
  }) async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      if (redirectOnFailure) {
        await _expireSession();
      }
      return false;
    }

    final result = await CognitoService.refreshSession(
      refreshToken: refreshToken,
      client: cognitoClient,
    );
    if (result['success'] == true) {
      final idToken = result['idToken'] as String?;
      final accessToken = result['accessToken'] as String?;
      if (idToken == null ||
          idToken.isEmpty ||
          accessToken == null ||
          accessToken.isEmpty) {
        if (redirectOnFailure) {
          await _expireSession();
        }
        return false;
      }

      await TokenStorage.updateTokens(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: result['refreshToken'] as String?,
        expiresIn: (result['expiresIn'] as num?)?.toInt(),
      );
      return true;
    }

    if (result['errorType']?.toString().contains('NotAuthorizedException') ==
            true ||
        result['error']?.toString().contains(
              'Your sign-in session has expired',
            ) ==
            true) {
      if (redirectOnFailure) {
        await _expireSession();
      }
      return false;
    }

    return false;
  }

  static Future<void> _expireSession() async {
    await TokenStorage.clearTokens();
    AppSession.showSessionExpired();
  }
}
