# Flutter authentication assessment

A null-safe Flutter app with Landing, Login, Sign Up and Dashboard screens, Provider state management and a simple Material 3 theme. The landing identity is TIH-inspired text, not an official logo. No backend, database or Firebase is used.

## Setup

Use Flutter with Dart 3.9.2 or newer, matching `pubspec.yaml`.

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

For Android, start an emulator or connect a phone with USB debugging enabled, then select its ID from `flutter devices` with `flutter run -d <device-id>`.

## Mock data and login

The seeded mock account is defined in the private `_accounts` map in `lib/services/mock_auth_service.dart`:

- Name: Telly
- Email: `telly@example.com`
- Password: `test123` (public test credential only)

Choose **Log In**, enter these credentials and view the profile on Dashboard. **Log out** returns to Landing. Email matching ignores surrounding whitespace and case; passwords are compared exactly. Restarting resets the session and recreates the same demo account.

**This is non-production authentication.** The service stores a test password in memory, seeded from a public demo literal in source code. Never enter real passwords or use this implementation in production. Credentials are excluded from `UserModel`, JSON, the dashboard and application logs. There is no hashing, secure storage, token management, persistence, email verification or recovery. Production authentication requires a secure backend and a different service implementation.

## Structure

```text
lib/
  main.dart                       App, theme, Provider and session gate
  theme/app_theme.dart            Shared orange, charcoal, white and grey Material 3 theme
  models/user_model.dart          Immutable public profile and JSON conversion
  services/mock_auth_service.dart Seeded account, registration and credential matching
  providers/auth_provider.dart    Session, loading, errors and logout
  screens/
    landing_screen.dart           Entry point
    login_screen.dart             Login screen
    sign_up_screen.dart           Registration form configuration
    dashboard_screen.dart         Static authenticated profile
  widgets/
    auth_form.dart                Login fields, validation and feedback
    content_panel.dart            Scrollable, width-constrained content
    app_button.dart               Shared primary action and loading feedback
    profile_icon.dart             Consistent orange icon tile
    welcome_illustration.dart     Decorative Flutter icons and shapes
    personal_info_row.dart        Reusable personal information row
test/
  auth_test.dart                  Model, service and Provider unit tests
  widget_test.dart                Validation and full login/logout flow
```

Provider is the only application dependency beyond Flutter. Flutter Test and Flutter Lints support development; platform scaffolding is retained.

## Navigation and state flow

`ChangeNotifierProvider` creates one `AuthProvider` above `MaterialApp` and disposes it automatically. The service is injected through the provider's constructor, allowing tests to use a zero-delay service.

The root authentication gate watches `isAuthenticated`, showing Landing when `user` is null and Dashboard otherwise. Sign Up opens the registration form and Log In opens Login using Navigator. Get Started remains removed. Registration collects full name, email and a password of at least six characters, then opens Login without creating an authenticated session. Registered accounts remain in memory until restart. A successful login removes the form route and reveals Dashboard at the root. Logout clears the session, so the root switches to Landing without leaving Dashboard in the back stack.

The form validates required fields and basic email format before calling Provider with `context.read`. Provider sets loading, clears previous errors and notifies listeners. The service simulates a 500 ms request and returns the matching profile or a friendly authentication error. Provider stores the profile on success and exposes a generic message for unexpected errors. A `finally` block resets loading and notifies listening widgets, which rebuild through `context.watch`.

Fields and submission are disabled while loading, and back navigation is blocked until completion. Provider also rejects overlapping submissions. The password controller is cleared after each attempted authentication. The dashboard displays the mock account's name and the email matched during login.

## JSON model

`UserModel` contains final `id`, `name` and `email` fields. `toJson()` returns only those fields, and `fromJson()` reconstructs the model from that map. JSON text can be produced with `jsonEncode(user.toJson())` and read with `UserModel.fromJson(jsonDecode(value) as Map<String, dynamic>)`.

Manual serialization keeps dependencies minimal for three fields. The decoder expects the documented schema and throws for missing or incorrectly typed fields; this assessment has no untrusted remote API. Passwords never belong in the public profile model.

## Tests

Unit tests cover JSON round trips and credential exclusion, seeded login, email normalization, incorrect/unknown credentials, loading notifications, overlapping requests, logout and safe unexpected errors. Widget tests cover required fields, invalid email, loading feedback, dashboard profile, logout, failed login and successful retry.

## Dashboard

The orange-and-charcoal dashboard reads the authenticated `UserModel` from Provider. Its welcome card and Personal Information card display the model name, matching account email and Logged in status. No profile values or credentials are hardcoded in dashboard widgets. A null user renders Login through a declarative guard. Logout clears Provider and removes routes above the root, preventing Back from reopening the dashboard. The root gate still returns to Landing after ordinary logout. The bottom logout action remains visible while profile cards scroll on small screens. The seeded demo account is recreated on restart. Tests also inject a different account to verify the dashboard uses actual state rather than the demo identity.

## TIH-inspired design

All screens share soft orange (#F4A66A), charcoal (#222222), white and light grey (#F5F5F5). Charcoal text on orange actions maintains readable contrast. The landing page uses a text-only TIH identity, an orange top accent, and a decorative account illustration made from Flutter shapes and icons. No official logo, external assets or new dependencies are used. Layouts scroll on compact devices and with larger accessibility text.

## Sign-up

Select **Sign Up** on Landing. Enter a full name, valid email and password of at least six characters, then select **Create account**. Successful registration replaces Sign Up with Login and shows an account-created message. Log in with the new credentials to see the captured name and normalized email on Dashboard. Logout clears the session; the registered account can log in again until the app restarts. Names are trimmed, email matching ignores case and surrounding whitespace, and duplicate email registration shows a friendly error. Test credentials stay only in the private service map and never enter UserModel, JSON, Dashboard or logs. This remains non-production authentication.

Verification after restoring sign-up: `flutter analyze` reports no issues, and all 15 unit/widget tests pass, including registration validation, duplicate emails and login after logout.

Form validation runs only when **Log in** or **Create account** is pressed. Typing, changing focus and the keyboard Done action do not trigger validation. Existing field errors are refreshed on the next button press.
