import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'content_panel.dart';
import 'app_button.dart';
import 'profile_icon.dart';

/// Shared login and registration form with local validation.
class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    this.isSignUp = false,
    this.onRegistered,
    this.registrationComplete = false,
  });
  final bool isSignUp;
  final VoidCallback? onRegistered;
  final bool registrationComplete;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final success = widget.isSignUp
        ? await auth.register(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          )
        : await auth.login(email: _email.text, password: _password.text);
    if (!mounted) return;
    _password.clear();
    if (!success) return;
    if (widget.isSignUp) {
      widget.onRegistered?.call();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return PopScope(
      canPop: !auth.isLoading,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.isSignUp ? 'Sign Up' : 'Log in')),
        body: ContentPanel(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: ProfileIcon(icon: Icons.lock_outline_rounded),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.isSignUp
                            ? 'Create your account'
                            : 'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isSignUp
                            ? 'Enter your details to get started.'
                            : 'Enter your details to access your account.',
                      ),
                      const SizedBox(height: 24),
                      if (widget.registrationComplete) ...[
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Account created. Please log in with your new details.',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (widget.isSignUp) ...[
                        TextFormField(
                          controller: _name,
                          enabled: !auth.isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          autofillHints: const [AutofillHints.name],
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Please enter your full name.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _email,
                        enabled: !auth.isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }
                          if (!RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(value.trim())) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        enabled: !auth.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: auth.isLoading
                                ? null
                                : () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (widget.isSignUp && value.length < 6) {
                            return 'Use at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            auth.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: widget.isSignUp ? 'Create account' : 'Log in',
                        onPressed: _submit,
                        isLoading: auth.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
