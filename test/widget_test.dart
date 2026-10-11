import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telesure_assessment/main.dart';
import 'package:telesure_assessment/services/mock_auth_service.dart';
import 'package:telesure_assessment/models/user_model.dart';
import 'package:telesure_assessment/providers/auth_provider.dart';
import 'package:telesure_assessment/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('login validation, loading, dashboard, logout and retry', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(authService: MockAuthService()));
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);

    await tester.enterText(field('Email'), 'invalid');
    await tester.enterText(field('Password'), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    await tester.enterText(field('Email'), 'Telly@example.com');
    await tester.enterText(field('Password'), 'test123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.pumpAndSettle();
    expect(find.text('My Dashboard'), findsOneWidget);
    expect(find.text('Welcome back, Telly!'), findsOneWidget);
    expect(find.text('Telly'), findsOneWidget);
    expect(find.text('Logged in'), findsOneWidget);
    expect(find.text('telly@example.com'), findsOneWidget);
    expect(find.text('test123'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);

    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('My Dashboard'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('My Dashboard'), findsNothing);
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Email'), 'telly@example.com');
    await tester.enterText(field('Password'), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(
      find.text('Email or password is incorrect. Please try again.'),
      findsOneWidget,
    );
    await tester.enterText(field('Password'), 'test123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('My Dashboard'), findsOneWidget);
  });
  for (final signUp in [false, true]) {
    testWidgets(
      '${signUp ? "Sign up" : "Login"} validates only on button press',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        final action = signUp ? 'Sign Up' : 'Log In';
        await tester.ensureVisible(find.text(action));
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        await tester.enterText(field('Email'), 'invalid');
        await tester.enterText(field('Password'), '123');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.text('Please enter a valid email address.'), findsNothing);
        expect(find.text('Please enter your full name.'), findsNothing);
        expect(find.text('Use at least 6 characters.'), findsNothing);
        final submit = find.widgetWithText(
          FilledButton,
          signUp ? 'Create account' : 'Log in',
        );
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );
        if (signUp) {
          expect(find.text('Please enter your full name.'), findsOneWidget);
          expect(find.text('Use at least 6 characters.'), findsOneWidget);
        }
        await tester.enterText(field('Email'), 'person@example.com');
        await tester.pump();
        // Existing feedback updates only when the button is pressed again.
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets(
    'compact login supports keyboard scrolling and password visibility',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(MyApp(authService: MockAuthService()));
      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Password'), 'test123');
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Password'),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isTrue,
      );
      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Password'),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isFalse,
      );
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Password'),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isTrue,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Log in').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'sign up opens login, then dashboard shows the captured account',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
      await tester.enterText(field('Full name'), 'Jamie Registered');
      await tester.enterText(field('Email'), 'bad-email');
      await tester.enterText(field('Password'), '123');
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      await tester.enterText(field('Email'), ' Jamie@example.com ');
      await tester.enterText(field('Password'), 'demo456');
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        find.text('Account created. Please log in with your new details.'),
        findsOneWidget,
      );
      expect(find.text('My Dashboard'), findsNothing);
      expect(find.text('Create account'), findsNothing);
      expect(field('Full name'), findsNothing);
      final loginContext = tester.element(field('Email'));
      expect(loginContext.read<AuthProvider>().user, isNull);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Password'),
                matching: find.byType(TextField),
              ),
            )
            .controller
            ?.text,
        isEmpty,
      );
      await tester.enterText(field('Email'), 'jamie@example.com');
      await tester.enterText(field('Password'), 'demo456');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log in'));
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Jamie Registered'), findsOneWidget);
      expect(find.text('jamie@example.com'), findsOneWidget);
      expect(find.text('demo456'), findsNothing);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('My Dashboard'), findsNothing);
      expect(find.text('Sign Up'), findsOneWidget);
    },
  );

  testWidgets(
    'duplicate sign up shows a friendly error without authentication',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Full name'), 'Other');
      await tester.enterText(field('Email'), 'TELLY@example.com');
      await tester.enterText(field('Password'), 'demo456');
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(
        find.text('An account with this email already exists. Please log in.'),
        findsOneWidget,
      );
      expect(find.text('My Dashboard'), findsNothing);
    },
  );

  testWidgets('landing wraps large text and scrolls on compact devices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    expect(find.text('TIH'), findsOneWidget);
    expect(find.text('A better way starts here.'), findsOneWidget);
    await tester.ensureVisible(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Log In').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unauthenticated dashboard shows login', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(MockAuthService()),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    expect(find.text('My Dashboard'), findsNothing);
    expect(field('Email'), findsOneWidget);
    expect(field('Password'), findsOneWidget);
  });

  testWidgets('dashboard displays the authenticated model on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _AlternateAccountService();
    final auth = AuthProvider(service);
    addTearDown(auth.dispose);
    await tester.runAsync(
      () => auth.login(email: 'another@example.com', password: 'test-only'),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    expect(find.text('Welcome back, Taylor Account Holder!'), findsOneWidget);
    expect(find.text('Taylor Account Holder'), findsOneWidget);
    expect(find.text('another@example.com'), findsOneWidget);
    expect(find.text('telly@example.com'), findsNothing);
    expect(find.text('test-only'), findsNothing);
    await tester.ensureVisible(find.text('Logged in'));
    expect(tester.takeException(), isNull);
    expect(find.text('Log out').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(auth.user, isNull);
    expect(field('Email'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('My Dashboard'), findsNothing);
  });
}

class _AlternateAccountService extends MockAuthService {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async =>
      UserModel(id: 'alternate', name: 'Taylor Account Holder', email: email);
}
