import '../models/user_model.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}


class MockAuthService {
  MockAuthService({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;
  final Map<String, ({UserModel user, String password})> _accounts = {
    'telly@example.com': (
      user: const UserModel(id: '1', name: 'Telly', email: 'telly@example.com'),
      password: 'test123', // Public demo password.
    ),
  };

  int _nextId = 2;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final key = normalizeEmail(email);
    if (_accounts.containsKey(key)) {
      throw const AuthException(
        'An account with this email already exists. Please log in.',
      );
    }
    final user = UserModel(id: '${_nextId++}', name: name.trim(), email: key);
    _accounts[key] = (user: user, password: password);
    return user;
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final account = _accounts[normalizeEmail(email)];
    if (account == null || account.password != password) {
      throw const AuthException(
        'Email or password is incorrect. Please try again.',
      );
    }
    return account.user;
  }
}
