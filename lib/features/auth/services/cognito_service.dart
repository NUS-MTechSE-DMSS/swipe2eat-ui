import 'dart:convert';
import 'package:http/http.dart' as http;

/// AWS Cognito Authentication Service
/// Handles user signup, signin, and token management
class CognitoService {
  static const String _cognitoEndpoint = 'https://cognito-idp.ap-southeast-1.amazonaws.com/';
  static const String _clientId = '1d1jkchdvgt5tldbb0hivruird';

  /// Sign up a new user with AWS Cognito
  /// Returns a map with 'success' boolean and optional 'userId' or 'error' message
  /// If signup requires email confirmation, returns {'success': true, 'requiresConfirmation': true, 'userId': '...'}
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? name,
    String? city,
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
          {
            'Name': 'email',
            'Value': email,
          },
          if (name != null && name.isNotEmpty)
            {
              'Name': 'name',
              'Value': name,
            },
          // NOTE: custom:City attribute configured in AWS Cognito User Pool (case-sensitive)
          if (city != null && city.isNotEmpty)
            {
              'Name': 'custom:City',
              'Value': city,
            },
        ],
      };

      final response = await http.post(
        Uri.parse(_cognitoEndpoint),
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
        final errorMessage = responseData['message'] as String? ?? 'Sign up failed';

        String userFriendlyMessage = errorMessage;

        // Map common Cognito errors to user-friendly messages
        if (errorType != null) {
          if (errorType.contains('UsernameExistsException')) {
            userFriendlyMessage = 'An account with this email already exists';
          } else if (errorType.contains('InvalidPasswordException')) {
            userFriendlyMessage = 'Password does not meet requirements. Use at least 8 characters with uppercase, lowercase, numbers, and special characters';
          } else if (errorType.contains('InvalidParameterException')) {
            // Check if it's a custom attribute schema error
            if (errorMessage.contains('custom:') || errorMessage.contains('schema')) {
              userFriendlyMessage = 'Custom attribute error. Please verify custom:City attribute exists in Cognito User Pool settings';
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
        Uri.parse(_cognitoEndpoint),
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
        final errorMessage = responseData['message'] as String? ?? 'Verification failed';

        String userFriendlyMessage = errorMessage;

        if (errorType != null) {
          if (errorType.contains('CodeMismatchException')) {
            userFriendlyMessage = 'Invalid verification code. Please try again';
          } else if (errorType.contains('ExpiredCodeException')) {
            userFriendlyMessage = 'Verification code has expired. Request a new one';
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
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
        'Content-Type': 'application/x-amz-json-1.1',
      };

      final body = {
        'ClientId': _clientId,
        'Username': email,
      };

      final response = await http.post(
        Uri.parse(_cognitoEndpoint),
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
        final errorMessage = responseData['message'] as String? ?? 'Failed to resend code';

        return {
          'success': false,
          'error': errorMessage,
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
        'AuthParameters': {
          'USERNAME': email,
          'PASSWORD': password,
        },
      };

      final response = await http.post(
        Uri.parse(_cognitoEndpoint),
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
        final errorMessage = responseData['message'] as String? ?? 'Sign in failed';

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
}
