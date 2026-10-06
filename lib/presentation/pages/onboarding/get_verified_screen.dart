import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'add_kids_screen.dart';

class GetVerifiedScreen extends StatelessWidget {
  const GetVerifiedScreen({super.key});

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
                'Let\'s get you\nverified',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Every parent is checked, so every ride is safe.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Text(
                '4 STEPS REMAINING',
                style: AppTextStyles.labelS
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildVerificationItem(
                icon: Icons.badge_outlined,
                title: 'Photo ID',
                subtitle: 'Government issued',
                isCompleted: true,
              ),
              _buildVerificationItem(
                icon: Icons.contact_emergency_outlined,
                title: 'Driving license',
                subtitle: 'Valid UK license',
                isCompleted: false,
              ),
              _buildVerificationItem(
                icon: Icons.gpp_good_outlined,
                title: 'Background check',
                subtitle: 'Clean criminal record',
                isCompleted: false,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgInverse,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'IN PROGRESS',
                    style: AppTextStyles.labelS
                        .copyWith(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
              _buildVerificationItem(
                icon: Icons.directions_car_outlined,
                title: 'Vehicle & insurance',
                subtitle: 'Registered & insured',
                isCompleted: false,
                isLast: true,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddKidsScreen()),
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

  Widget _buildVerificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lime,
            radius: 20,
            child: Icon(icon, color: AppColors.ink, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelL),
                Text(subtitle,
                    style: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (isCompleted)
            const Text('Done',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
          else
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
