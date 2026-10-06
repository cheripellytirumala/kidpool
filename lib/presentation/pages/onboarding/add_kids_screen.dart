import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'join_circle_screen.dart';

class AddKidsScreen extends StatelessWidget {
  const AddKidsScreen({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Add your kids',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'So other parents and teachers know exactly who to look out for.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.ink,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Charlie Mitchell',
                                  style: AppTextStyles.headingH2),
                              Text('Tap to edit photo',
                                  style: AppTextStyles.bodyS.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.bgSurfaceStrong,
                          child:
                              Icon(Icons.edit, size: 16, color: AppColors.ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(Icons.school_outlined, 'Lincoln Elementary'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoRow(Icons.numbers, '3')),
                        const SizedBox(width: 12),
                        Expanded(
                            child:
                                _buildInfoRow(Icons.keyboard_arrow_right, 'A')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.medical_services_outlined,
                        'Peanut allergy - EpiPen in bag'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        Icons.phone_outlined, 'My #: +44 789 222 999'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.bgSurfaceStrong),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        size: 20, color: AppColors.ink),
                    const SizedBox(width: 8),
                    Text('Add another child', style: AppTextStyles.labelL),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Save & continue',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JoinCircleScreen()),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.ink),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyM),
        ],
      ),
    );
  }
}
