import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class JoinCircleScreen extends StatelessWidget {
  const JoinCircleScreen({super.key});

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
              icon: const Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
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
                'Join your\nschool circle',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Only verified parents near Lincoln Elementary can see your requests.',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.bgInverse,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder for map background
                      Center(
                        child: CustomPaint(
                          painter: CircleGridPainter(),
                          size: const Size(double.infinity, double.infinity),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.lime.withOpacity(0.5),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lime.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.lime, size: 32),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people, size: 14, color: AppColors.ink),
                                  const SizedBox(width: 4),
                                  Text('142 verified parents', style: AppTextStyles.labelS),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active circles', style: AppTextStyles.labelM),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildCircleTag('7:45 AM'),
                                  const SizedBox(width: 8),
                                  _buildCircleTag('8:00 AM', isSelected: true),
                                  const SizedBox(width: 8),
                                  _buildCircleTag('8:15 AM'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Join circle',
                onPressed: () {
                  // Complete onboarding
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleTag(String time, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.ink : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        time,
        style: AppTextStyles.labelS.copyWith(
          color: isSelected ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class CircleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.charcoal.withOpacity(0.3)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
