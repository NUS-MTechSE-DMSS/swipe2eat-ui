import 'dart:convert';
import 'package:http/http.dart' as http;

/// AWS Cognito Authentication Service
/// Handles user signup, signin, and token management
class CognitoService {
  static const String _cognitoEndpoint =
      'https://cognito-idp.ap-southeast-1.amazonaws.com/';
  static const String _clientId = '1d1jkchdvgt5tldbb0hivruird';
  static Uri get _cognitoUri => Uri.parse(_cognitoEndpoint);

  /// Sign up a new user with AWS Cognito
  /// Returns a map with 'success' boolean and optional 'userId' or 'error' message
  /// If signup requires email confirmation, returns {'success': true, 'requiresConfirmation': true, 'userId': '...'}
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? name,
    String? city,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'ClientId': _clientId,
        'Username': email,
        'Password': password,
        'UserAttributes': [
          {'Name': 'email', 'Value': email},
          if (name != null && name.isNotEmpty) {'Name': 'name', 'Value': name},
          if (gender != null && gender.isNotEmpty)
            {'Name': 'gender', 'Value': gender},
          if (dateOfBirth != null)
            {
              'Name': 'birthdate',
              'Value': dateOfBirth.toIso8601String().split('T').first,
            },
          // NOTE: custom:City attribute configured in AWS Cognito User Pool (case-sensitive)
          if (city != null && city.isNotEmpty)
            {'Name': 'custom:City', 'Value': city},
        ],
      };

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Successful signup
        final userSub = responseData['UserSub'] as String?;
        final userConfirmed = responseData['UserConfirmed'] as bool? ?? false;

        return {
          'success': true,
          'userId': userSub,
          'requiresConfirmation': !userConfirmed,
          'message': userConfirmed
              ? 'Account created successfully!'
              : 'Please check your email for verification code',
        };
      } else {
        // Handle Cognito errors
        final errorType = responseData['__type'] as String?;
        final errorMessage =
            responseData['message'] as String? ?? 'Sign up failed';

        String userFriendlyMessage = errorMessage;

        // Map common Cognito errors to user-friendly messages
        if (errorType != null) {
          if (errorType.contains('UsernameExistsException')) {
            userFriendlyMessage = 'An account with this email already exists';
          } else if (errorType.contains('InvalidPasswordException')) {
            userFriendlyMessage =
                'Password does not meet requirements. Use at least 8 characters with uppercase, lowercase, numbers, and special characters';
          } else if (errorType.contains('InvalidParameterException')) {
            // Check if it's a custom attribute schema error
            if (errorMessage.contains('custom:') ||
                errorMessage.contains('schema')) {
              userFriendlyMessage =
                  'Custom attribute error. Please verify custom:City attribute exists in Cognito User Pool settings';
            } else {
              userFriendlyMessage = 'Invalid email or password format';
            }
          } else if (errorType.contains('TooManyRequestsException')) {
            userFriendlyMessage = 'Too many requests. Please try again later';
          }
        }

        return {
          'success': false,
          'error': userFriendlyMessage,
          'errorType': errorType,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Confirm user signup with verification code sent to email
  static Future<Map<String, dynamic>> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmSignUp',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'ClientId': _clientId,
        'Username': email,
        'ConfirmationCode': confirmationCode,
      };

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully! You can now sign in.',
        };
      } else {
        final responseData = jsonDecode(response.body);
        final errorType = responseData['__type'] as String?;
        final errorMessage =
            responseData['message'] as String? ?? 'Verification failed';

        String userFriendlyMessage = errorMessage;

        if (errorType != null) {
          if (errorType.contains('CodeMismatchException')) {
            userFriendlyMessage = 'Invalid verification code. Please try again';
          } else if (errorType.contains('ExpiredCodeException')) {
            userFriendlyMessage =
                'Verification code has expired. Request a new one';
          } else if (errorType.contains('NotAuthorizedException')) {
            userFriendlyMessage = 'User is already confirmed';
          }
        }

        return {
          'success': false,
          'error': userFriendlyMessage,
          'errorType': errorType,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Resend confirmation code to user's email
  static Future<Map<String, dynamic>> resendConfirmationCode({
    required String email,
  }) async {
    try {
      final headers = {
        'X-Amz-Target':
            'AWSCognitoIdentityProviderService.ResendConfirmationCode',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {'ClientId': _clientId, 'Username': email};

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification code sent to your email',
        };
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] as String? ?? 'Failed to resend code';

        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Request a password reset code for the user.
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.ForgotPassword',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {'ClientId': _clientId, 'Username': email};

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset code sent to your email',
        };
      }

      final responseData = jsonDecode(response.body);
      final errorType = responseData['__type'] as String?;
      final errorMessage =
          responseData['message'] as String? ??
          'Failed to send password reset code';

      String userFriendlyMessage = errorMessage;

      if (errorType != null) {
        if (errorType.contains('UserNotFoundException')) {
          userFriendlyMessage = 'No account found for this email';
        } else if (errorType.contains('InvalidParameterException')) {
          userFriendlyMessage = 'Please enter a valid email address';
        } else if (errorType.contains('LimitExceededException') ||
            errorType.contains('TooManyRequestsException')) {
          userFriendlyMessage = 'Too many requests. Please try again later';
        }
      }

      return {
        'success': false,
        'error': userFriendlyMessage,
        'errorType': errorType,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Confirm a password reset with the code sent to the user's email.
  static Future<Map<String, dynamic>> confirmForgotPassword({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    try {
      final headers = {
        'X-Amz-Target':
            'AWSCognitoIdentityProviderService.ConfirmForgotPassword',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'ClientId': _clientId,
        'Username': email,
        'ConfirmationCode': confirmationCode,
        'Password': newPassword,
      };

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successful. You can now sign in.',
        };
      }

      final responseData = jsonDecode(response.body);
      final errorType = responseData['__type'] as String?;
      final errorMessage =
          responseData['message'] as String? ?? 'Password reset failed';

      String userFriendlyMessage = errorMessage;

      if (errorType != null) {
        if (errorType.contains('CodeMismatchException')) {
          userFriendlyMessage = 'Invalid reset code. Please try again';
        } else if (errorType.contains('ExpiredCodeException')) {
          userFriendlyMessage = 'Reset code has expired. Request a new one';
        } else if (errorType.contains('InvalidPasswordException')) {
          userFriendlyMessage =
              'Password does not meet requirements. Use at least 8 characters with uppercase, lowercase, numbers, and special characters';
        } else if (errorType.contains('UserNotFoundException')) {
          userFriendlyMessage = 'No account found for this email';
        }
      }

      return {
        'success': false,
        'error': userFriendlyMessage,
        'errorType': errorType,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Sign in user with email and password
  /// Returns tokens (IdToken, AccessToken, RefreshToken) on success
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'AuthFlow': 'USER_PASSWORD_AUTH',
        'ClientId': _clientId,
        'AuthParameters': {'USERNAME': email, 'PASSWORD': password},
      };

      final response = await http.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResult = responseData['AuthenticationResult'];

        if (authResult != null) {
          return {
            'success': true,
            'idToken': authResult['IdToken'],
            'accessToken': authResult['AccessToken'],
            'refreshToken': authResult['RefreshToken'],
            'expiresIn': authResult['ExpiresIn'],
            'tokenType': authResult['TokenType'],
          };
        } else {
          // Handle challenges (e.g., NEW_PASSWORD_REQUIRED)
          final challengeName = responseData['ChallengeName'];
          return {
            'success': false,
            'requiresChallenge': true,
            'challenge': challengeName,
            'error': 'Additional authentication step required',
          };
        }
      } else {
        final errorType = responseData['__type'] as String?;
        final errorMessage =
            responseData['message'] as String? ?? 'Sign in failed';

        String userFriendlyMessage = errorMessage;

        if (errorType != null) {
          if (errorType.contains('NotAuthorizedException')) {
            userFriendlyMessage = 'Incorrect email or password';
          } else if (errorType.contains('UserNotConfirmedException')) {
            userFriendlyMessage = 'Please verify your email before signing in';
          } else if (errorType.contains('UserNotFoundException')) {
            userFriendlyMessage = 'No account found with this email';
          } else if (errorType.contains('TooManyRequestsException')) {
            userFriendlyMessage = 'Too many attempts. Please try again later';
          }
        }

        return {
          'success': false,
          'error': userFriendlyMessage,
          'errorType': errorType,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    }
  }

  /// Refresh the Cognito session using a stored refresh token.
  static Future<Map<String, dynamic>> refreshSession({
    required String refreshToken,
    http.Client? client,
  }) async {
    http.Client? ownedClient;

    try {
      final effectiveClient = client ?? (ownedClient = http.Client());
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'AuthFlow': 'REFRESH_TOKEN_AUTH',
        'ClientId': _clientId,
        'AuthParameters': {'REFRESH_TOKEN': refreshToken},
      };

      final response = await effectiveClient.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResult =
            responseData['AuthenticationResult'] as Map<String, dynamic>?;
        if (authResult == null) {
          return {'success': false, 'error': 'Session refresh failed'};
        }

        return {
          'success': true,
          'idToken': authResult['IdToken'],
          'accessToken': authResult['AccessToken'],
          'refreshToken': authResult['RefreshToken'],
          'expiresIn': authResult['ExpiresIn'],
          'tokenType': authResult['TokenType'],
        };
      }

      final errorType = responseData['__type'] as String?;
      final errorMessage =
          responseData['message'] as String? ?? 'Session refresh failed';

      var userFriendlyMessage = errorMessage;
      if (errorType != null) {
        if (errorType.contains('NotAuthorizedException')) {
          userFriendlyMessage =
              'Your sign-in session has expired. Please sign in again.';
        } else if (errorType.contains('TooManyRequestsException')) {
          userFriendlyMessage = 'Too many requests. Please try again later';
        }
      }

      return {
        'success': false,
        'error': userFriendlyMessage,
        'errorType': errorType,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    } finally {
      ownedClient?.close();
    }
  }

  /// Delete the currently signed-in Cognito user using the access token.
  static Future<Map<String, dynamic>> deleteUser({
    required String accessToken,
    http.Client? client,
  }) async {
    http.Client? ownedClient;

    try {
      final effectiveClient = client ?? (ownedClient = http.Client());
      final headers = {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.DeleteUser',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final response = await effectiveClient.post(
        _cognitoUri,
        headers: headers,
        body: jsonEncode({'AccessToken': accessToken}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Account deleted successfully.'};
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final errorType = responseData['__type'] as String?;
      final errorMessage =
          responseData['message'] as String? ?? 'Failed to delete account';

      var userFriendlyMessage = errorMessage;

      if (errorType != null) {
        if (errorType.contains('NotAuthorizedException')) {
          userFriendlyMessage =
              'Your sign-in session expired. Please sign in again and retry deleting your account.';
        } else if (errorType.contains('UserNotFoundException')) {
          userFriendlyMessage = 'Your sign-in account was already deleted.';
        } else if (errorType.contains('TooManyRequestsException')) {
          userFriendlyMessage = 'Too many requests. Please try again later.';
        }
      }

      return {
        'success': false,
        'error': userFriendlyMessage,
        'errorType': errorType,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please check your connection and try again',
        'details': e.toString(),
      };
    } finally {
      ownedClient?.close();
    }
  }
}
