import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/landing_screen.dart';
import 'services/mock_auth_service.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.authService});
  final MockAuthService? authService;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AuthProvider(authService ?? MockAuthService()),
    child: MaterialApp(
      title: 'Account Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    ),
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) =>
      context.watch<AuthProvider>().isAuthenticated
      ? const DashboardScreen()
      : const LandingScreen();
}
