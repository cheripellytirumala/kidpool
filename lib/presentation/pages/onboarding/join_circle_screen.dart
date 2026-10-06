import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/primary_button.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().loadCircles();
    });
  }

  Future<void> _handleJoin() async {
    final provider = context.read<OnboardingProvider>();
    final circles = provider.circles;
    final success = circles.isEmpty
        ? await provider.startCircle()
        : await provider
            .joinCircle(circles[_selected.clamp(0, circles.length - 1)]);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      success
          ? SnackBar(
              content: Text(
                provider.ownsJoinedCircle
                    ? "Your circle is ready. Other parents can now ask to join."
                    : 'Request sent. The circle owner will approve you.',
              ),
            )
          : SnackBar(
              content:
                  Text(provider.errorMessage ?? 'Could not join the circle'),
              backgroundColor: AppColors.statusSos,
            ),
    );
  }

  String _buttonText(OnboardingProvider provider) {
    if (provider.joinedCircle != null) {
      return provider.ownsJoinedCircle ? "You're in" : 'Request sent';
    }
    if (provider.isLoading) return 'Please wait...';
    return provider.circles.isEmpty ? 'Start a circle' : 'Join circle';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final schoolName = provider.circleSchool?.name ?? 'your school';
    final circles = provider.circles;

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
              Text('Join your\nschool circle', style: AppTextStyles.headingH1),
              const SizedBox(height: AppSpacing.x12),
              Text(
                'Only verified parents near $schoolName can see your requests.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.x32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.bgInverse,
                    borderRadius: AppRadius.xlAll,
                  ),
                  child: Stack(
                    children: [
                      // "Dark = focus" — the map goes dark so the circle pops.
                      Positioned.fill(
                        child: CustomPaint(painter: CircleGridPainter()),
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
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(AppSpacing.x4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lime.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.lime,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.x8),
                            AppBadge(
                              label: circles.length == 1
                                  ? '1 active circle'
                                  : '${circles.length} active circles',
                              tone: AppBadgeTone.light,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: AppSpacing.x24,
                        left: AppSpacing.x24,
                        right: AppSpacing.x24,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.x16),
                          decoration: BoxDecoration(
                            color: AppColors.bgScreen,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active circles',
                                style: AppTextStyles.labelM,
                              ),
                              const SizedBox(height: AppSpacing.x12),
                              if (circles.isEmpty)
                                Text(
                                  provider.isLoading
                                      ? 'Loading circles...'
                                      : 'No circles here yet. Start the first one.',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: AppSpacing.x8,
                                  runSpacing: AppSpacing.x8,
                                  children: [
                                    for (int i = 0; i < circles.length; i++)
                                      AppChip(
                                        label: circles[i].name,
                                        selected: _selected == i,
                                        onTap: provider.joinedCircle == null
                                            ? () =>
                                                setState(() => _selected = i)
                                            : null,
                                      ),
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
              const SizedBox(height: AppSpacing.x32),
              PrimaryButton(
                text: _buttonText(provider),
                onPressed: provider.isLoading ||
                        provider.joinedCircle != null ||
                        provider.circleSchool == null
                    ? null
                    : _handleJoin,
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bgInverseRaised
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
