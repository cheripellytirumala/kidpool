import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_circle_map.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/fill_scroll_view.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';

/// One ride-radius option: the chip label, its metric readout, and how big
/// the catchment ring is drawn on the map.
class _RadiusOption {
  final String label;
  final String metric;
  final double ringFraction;

  const _RadiusOption(this.label, this.metric, this.ringFraction);
}

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  static const List<_RadiusOption> _radii = [
    _RadiusOption('0.5 mi', '≈ 0.8 km', 0.275),
    _RadiusOption('1 mi', '≈ 1.6 km', 0.367),
    _RadiusOption('1.5 mi', '≈ 2.4 km', 0.44),
    _RadiusOption('2 mi', '≈ 3.2 km', 0.49),
  ];

  // "1 mi" is the default selection in the design.
  int _radius = 1;

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
        : await provider.joinCircle(circles.first);
    if (!mounted) return;

    if (success) {
      await showAppAlert(
        context,
        type: AppAlertType.success,
        title: provider.ownsJoinedCircle ? 'Circle created' : 'Request sent',
        message: provider.ownsJoinedCircle
            ? 'Your circle is ready. Other parents can now ask to join.'
            : 'The circle owner will approve you.',
      );
      if (!mounted) return;
      // Onboarding is done: Home becomes the root of the app.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      showAppAlert(
        context,
        type: AppAlertType.error,
        message: provider.errorMessage ?? 'Could not join the circle.',
      );
    }
  }

  String _buttonText(OnboardingProvider provider) {
    if (provider.joinedCircle != null) {
      return provider.ownsJoinedCircle ? "You're in" : 'Request sent';
    }
    if (provider.isLoading) return 'Please wait...';
    return provider.circles.isEmpty ? 'Start a circle' : 'Join circle';
  }

  /// The map's trust pill. We have no verified-parent count yet, so it
  /// reports the circles actually found near the school.
  String _trustLabel(OnboardingProvider provider) {
    if (provider.isLoading) return 'Finding parents...';
    final count = provider.circles.length;
    if (count == 0) return 'Verified parents only';
    return count == 1 ? '1 circle nearby' : '$count circles nearby';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final schoolName = provider.circleSchool?.name ?? 'your school';
    final option = _radii[_radius];

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x16,
                AppSpacing.x4,
                AppSpacing.x16,
                AppSpacing.x8,
              ),
              child: AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x16,
                  AppSpacing.x12,
                  AppSpacing.x16,
                  AppSpacing.x32,
                ),
                child: FillScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join your\nschool circle',
                              style: AppTextStyles.displayL,
                            ),
                            const SizedBox(height: AppSpacing.x12),
                            Text(
                              'Only verified parents near $schoolName see your requests.',
                              style: AppTextStyles.bodyL
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x20),
                      AppCircleMap(
                        schoolName: schoolName,
                        trustLabel: _trustLabel(provider),
                        radiusFraction: option.ringFraction,
                      ),
                      const SizedBox(height: AppSpacing.x20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Ride radius',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelL,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x8),
                            Text(
                              option.metric,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelM
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x12),
                      Row(
                        children: [
                          for (int i = 0; i < _radii.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.x8),
                            Expanded(
                              child: AppChip(
                                label: _radii[i].label,
                                selected: _radius == i,
                                onTap: () => setState(() => _radius = i),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      PrimaryButton(
                        text: _buttonText(provider),
                        onPressed: provider.isLoading ||
                                provider.joinedCircle != null ||
                                provider.circleSchool == null
                            ? null
                            : _handleJoin,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
