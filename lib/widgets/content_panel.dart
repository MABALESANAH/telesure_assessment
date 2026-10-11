import 'package:flutter/material.dart';

/// Scrollable, width-constrained content for phones, keyboards and desktops.
class ContentPanel extends StatelessWidget {
  const ContentPanel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    ),
  );
}
