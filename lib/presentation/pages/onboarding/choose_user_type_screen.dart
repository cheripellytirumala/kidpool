import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user_role.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/primary_button.dart';
import 'get_verified_screen.dart';

class ChooseUserTypeScreen extends StatefulWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  State<ChooseUserTypeScreen> createState() => _ChooseUserTypeScreenState();
}

class _ChooseUserTypeScreenState extends State<ChooseUserTypeScreen> {
  int selectedType = 0; // 0 for parent, 1 for staff

  Future<void> _handleContinue() async {
    final provider = context.read<OnboardingProvider>();
    final role = selectedType == 0 ? UserRole.parent : UserRole.staff;
    final success = await provider.saveRole(role);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GetVerifiedScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Could not save your role'),
          backgroundColor: AppColors.statusSos,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenGutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.x8),
              AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.x32),
              Text('How will you\nuse kidpool?', style: AppTextStyles.displayL),
              const SizedBox(height: AppSpacing.x40),
              _buildTypeOption(
                index: 0,
                title: "I'm a parent",
                subtitle: 'Ask for rides and lend a hand to families near you.',
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: AppSpacing.x24),
              _buildTypeOption(
                index: 1,
                title: "I'm school staff",
                subtitle: 'Scan ride passes and check kids in at arrival.',
                icon: Icons.school_outlined,
              ),
              const Spacer(),
              Center(
                child: Text(
                  'You can switch roles anytime in Settings',
                  style: AppTextStyles.labelS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.x24),
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: provider.isLoading ? 'Saving...' : 'Continue',
                    onPressed: provider.isLoading ? null : _handleContinue,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.x24),
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
    final bool isSelected = selectedType == index;
    return GestureDetector(
      onTap: () => setState(() => selectedType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.x24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime : AppColors.bgSurface,
          borderRadius: AppRadius.xlAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.ink : AppColors.bgScreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.lime : AppColors.ink,
                    size: 24,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.ink : AppColors.bgScreen,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.lime, size: 20)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x24),
            Text(title, style: AppTextStyles.headingH2),
            const SizedBox(height: AppSpacing.x8),
            Text(
              subtitle,
              style: AppTextStyles.bodyM.copyWith(
                color: isSelected ? AppColors.ink : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
