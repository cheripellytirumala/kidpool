import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'get_verified_screen.dart';

class ChooseUserTypeScreen extends StatefulWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  State<ChooseUserTypeScreen> createState() => _ChooseUserTypeScreenState();
}

class _ChooseUserTypeScreenState extends State<ChooseUserTypeScreen> {
  int selectedType = 0; // 0 for parent, 1 for staff

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.bgSurface,
            child: IconButton(
              icon:
                  const Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'How will you\nuse kidpool?',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 32),
              _buildTypeOption(
                index: 0,
                title: 'I\'m a parent',
                subtitle: 'Safe for rides and errands to families near you.',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTypeOption(
                index: 1,
                title: 'I\'m school staff',
                subtitle: 'Supervise the runs kids trust and visit.',
                icon: Icons.school,
              ),
              const Spacer(),
              Text(
                'Learn about role differences in settings',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const GetVerifiedScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = selectedType == index;
    return GestureDetector(
      onTap: () => setState(() => selectedType = index),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeSoft : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border:
              isSelected ? Border.all(color: AppColors.lime, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.ink,
                  radius: 20,
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (isSelected)
                  const CircleAvatar(
                    backgroundColor: AppColors.lime,
                    radius: 12,
                    child: Icon(Icons.check, color: AppColors.ink, size: 16),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.bgSurfaceStrong, width: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headingH2,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
