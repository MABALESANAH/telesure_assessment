import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.registrationComplete = false});
  final bool registrationComplete;
  @override
  Widget build(BuildContext context) =>
      AuthForm(registrationComplete: registrationComplete);
}
