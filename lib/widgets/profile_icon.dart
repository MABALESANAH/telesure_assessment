import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({
    super.key,
    this.icon = Icons.person_outline_rounded,
    this.size = 64,
  });
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: Icon(
      icon,
      size: size * 0.5,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
