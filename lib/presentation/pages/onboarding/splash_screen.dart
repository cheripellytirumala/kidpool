import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // "Dark = focus" — the splash is one of the dark moments in the system.
    return Scaffold(
      backgroundColor: AppColors.bgInverse,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.route,
                      size: 48,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x24),
                  Text(
                    'kidpool',
                    style: AppTextStyles.displayL
                        .copyWith(color: AppColors.textOnDark),
                  ),
                  const SizedBox(height: AppSpacing.x12),
                  Text(
                    'Rides you can trust,\nfrom parents you know.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyM
                        .copyWith(color: AppColors.textOnDarkMuted),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(width: 24, color: AppColors.lime),
                    const SizedBox(width: AppSpacing.x8),
                    _dot(width: 8, color: AppColors.charcoal),
                    const SizedBox(width: AppSpacing.x8),
                    _dot(width: 8, color: AppColors.charcoal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({required double width, required Color color}) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pill,
      ),
    );
  }
}
