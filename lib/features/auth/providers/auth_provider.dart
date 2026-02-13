// Auth provider
import '../models/user_model.dart';
import '../services/auth_api.dart';

class AuthProvider {
  final AuthApi _authApi = AuthApi();
  UserModel? _user;

  UserModel? get user => _user;

  Future<bool> signIn(String email, String password) async {
    final success = await _authApi.signIn(email, password);
    if (success) {
      // TODO: Set user
    }
    return success;
  }

  Future<bool> signUp(String email, String password) async {
    final success = await _authApi.signUp(email, password);
    if (success) {
      // TODO: Set user
    }
    return success;
  }
}
