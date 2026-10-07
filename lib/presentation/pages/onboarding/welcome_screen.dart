import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/fill_scroll_view.dart';
import '../../widgets/app_route_map.dart';
import '../../widgets/primary_button.dart';
import 'phone_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenGutter,
          child: FillScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.x40),
              // Display/L — the hero headline moment.
              Text('School runs,\nshared.', style: AppTextStyles.displayL),
              const SizedBox(height: AppSpacing.x16),
              Text(
                'Free carpooling with verified parents from your kid\'s school.',
                style: AppTextStyles.bodyL
                    .copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              const AppRouteMap(),
              const Spacer(),
              PrimaryButton(
                text: 'Get started',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PhoneScreen()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.x16),
              Center(
                child: Text(
                  'Already have an account?',
                  style: AppTextStyles.labelM,
                ),
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          )),
        ),
      ),
    );
  }
}
