import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);
  final MockAuthService _service;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login({required String email, required String password}) =>
      _authenticate(() => _service.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) => _authenticate(
    () => _service.register(name: name, email: email, password: password),
    signIn: false,
  );

  Future<bool> _authenticate(
    Future<UserModel> Function() operation, {
    bool signIn = true,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await operation();
      if (signIn) _user = profile;
      return true;
    } on AuthException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void logout() {
    if (_isLoading) return;
    _user = null;
    _error = null;
    notifyListeners();
  }
}
