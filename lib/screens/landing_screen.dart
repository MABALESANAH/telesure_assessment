import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/content_panel.dart';
import '../widgets/app_button.dart';
import '../widgets/welcome_illustration.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    context.read<AuthProvider>().clearError();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          Container(height: 5, color: AppTheme.orange),
          Expanded(
            child: ContentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'TIH',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Telesure Investment Holdings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A better way starts here.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your account, made simple.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const WelcomeIllustration(),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Sign Up',
                    onPressed: () => _open(context, const SignUpScreen()),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _open(context, const LoginScreen()),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
