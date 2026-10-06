import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'School runs,\nshared.',
                style: AppTextStyles.headingH1.copyWith(
                  fontSize: 40,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Free carpooling with verified parents from your kid\'s school.',
                style: AppTextStyles.bodyL.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.bgInverse,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder for map/route design
                      Center(
                        child: Icon(
                          Icons.map_outlined,
                          color: AppColors.lime.withOpacity(0.2),
                          size: 200,
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Emma started at 8:02 AM',
                                style: AppTextStyles.labelS,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Get started',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PhoneScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Already have an account?',
                  style: AppTextStyles.labelM,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
