import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) => AuthForm(
    isSignUp: true,
    onRegistered: () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(registrationComplete: true),
        ),
      );
    },
  );
}
