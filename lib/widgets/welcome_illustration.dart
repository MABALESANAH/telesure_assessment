import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Decorative account illustration drawn entirely with Flutter widgets.
class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 1.7,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width * .6,
                height: width * .6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0E5),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                top: 16,
                right: width * .12,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppTheme.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Transform.rotate(
                angle: -.06,
                child: Container(
                  width: width * .56,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12222222),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFFFF0E5),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.charcoal,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 7,
                        width: width * .24,
                        decoration: BoxDecoration(
                          color: AppTheme.charcoal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 6,
                        width: width * .32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                right: width * .15,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.orange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.charcoal,
                    size: 24,
                  ),
                ),
              ),
              Positioned(
                left: width * .1,
                bottom: 30,
                child: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.orange,
                  size: 26,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
