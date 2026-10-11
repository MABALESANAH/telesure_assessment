import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:telesure_assessment/models/user_model.dart';
import 'package:telesure_assessment/providers/auth_provider.dart';
import 'package:telesure_assessment/services/mock_auth_service.dart';

void main() {
  test('profile JSON round trips and excludes credentials', () {
    const user = UserModel(id: '1', name: 'Telly', email: 'telly@example.com');
    final json = user.toJson();
    expect(json.keys, unorderedEquals(['id', 'name', 'email']));
    final restored = UserModel.fromJson(
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
    );
    expect(restored.id, user.id);
    expect(restored.name, user.name);
    expect(restored.email, user.email);
  });

  test(
    'seeded mock login normalizes email and validates credentials',
    () async {
      final service = MockAuthService(delay: Duration.zero);
      final user = await service.login(
        email: ' TELLY@example.com ',
        password: 'test123',
      );
      expect(user.name, 'Telly');
      expect(user.email, 'telly@example.com');
      await expectLater(
        service.login(email: user.email, password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        service.login(email: 'unknown@example.com', password: 'test123'),
        throwsA(isA<AuthException>()),
      );
    },
  );

  test(
    'provider publishes loading, prevents overlapping requests and manages session',
    () async {
      final auth = AuthProvider(MockAuthService(delay: Duration.zero));
      addTearDown(auth.dispose);
      final loadingStates = <bool>[];
      auth.addListener(() => loadingStates.add(auth.isLoading));
      final login = auth.login(email: 'telly@example.com', password: 'test123');
      expect(auth.isLoading, isTrue);
      expect(
        await auth.login(email: 'telly@example.com', password: 'test123'),
        isFalse,
      );
      expect(await login, isTrue);
      expect(loadingStates, [true, false]);
      expect(auth.isAuthenticated, isTrue);
      auth.logout();
      expect(auth.user, isNull);
      expect(
        await auth.login(email: 'telly@example.com', password: 'bad'),
        isFalse,
      );
      expect(auth.error, isNotNull);
      expect(auth.isLoading, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(
        await auth.login(email: 'telly@example.com', password: 'test123'),
        isTrue,
      );
      expect(auth.error, isNull);
    },
  );

  test(
    'registration normalizes profiles, assigns IDs and rejects duplicates',
    () async {
      final service = MockAuthService(delay: Duration.zero);
      final user = await service.register(
        name: ' Jamie ',
        email: ' JAMIE@example.com ',
        password: 'demo456',
      );
      expect(user.name, 'Jamie');
      expect(user.email, 'jamie@example.com');
      expect(user.id, isNot('1'));
      expect(
        await service.login(email: 'Jamie@example.com', password: 'demo456'),
        same(user),
      );
      expect(user.toJson().keys, unorderedEquals(['id', 'name', 'email']));
      await expectLater(
        service.register(
          name: 'Other',
          email: 'Jamie@example.com',
          password: 'demo789',
        ),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        service.login(email: user.email, password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
    },
  );

  test(
    'registration creates an account without authenticating until login',
    () async {
      final auth = AuthProvider(MockAuthService(delay: Duration.zero));
      addTearDown(auth.dispose);
      final result = auth.register(
        name: 'Jamie',
        email: 'jamie@example.com',
        password: 'demo456',
      );
      expect(auth.isLoading, isTrue);
      expect(await result, isTrue);
      expect(auth.user, isNull);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.isLoading, isFalse);
      expect(
        await auth.login(email: 'jamie@example.com', password: 'demo456'),
        isTrue,
      );
      expect(auth.user?.name, 'Jamie');
    },
  );

  test('unexpected failures produce a safe error and stop loading', () async {
    final auth = AuthProvider(_FailingService());
    addTearDown(auth.dispose);
    expect(
      await auth.login(email: 'telly@example.com', password: 'test123'),
      isFalse,
    );
    expect(auth.error, 'Something went wrong. Please try again.');
    expect(auth.isLoading, isFalse);
  });
}

class _FailingService extends MockAuthService {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    throw StateError('Internal details');
  }
}
