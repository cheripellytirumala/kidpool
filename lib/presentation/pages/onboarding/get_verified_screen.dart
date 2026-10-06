import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/verification_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_toggle.dart';
import '../../widgets/primary_button.dart';
import '../verification/background_check_screen.dart';
import '../verification/background_check_status_screen.dart';
import '../verification/driving_record_screen.dart';
import '../verification/scan_photo_id_screen.dart';
import '../verification/vehicle_details_screen.dart';
import '../verification/verified_success_screen.dart';

/// 06 · Get Verified — the checklist that drives the V1–V9 verification flow.
///
/// Every row starts pending ("0 of 4 complete") and fills in as the parent
/// finishes each step.
class GetVerifiedScreen extends StatelessWidget {
  const GetVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x16,
                  AppSpacing.x12,
                  AppSpacing.x16,
                  AppSpacing.x32,
                ),
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
                            "Let's get you\nverified",
                            style: AppTextStyles.displayL,
                          ),
                          const SizedBox(height: AppSpacing.x12),
                          Text(
                            'Every parent is checked, so every ride is safe.',
                            style: AppTextStyles.bodyL
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x20),
                    _progress(provider),
                    const SizedBox(height: AppSpacing.x20),
                    _photoIdRow(context, provider),
                    const SizedBox(height: 10),
                    _backgroundRow(context, provider),
                    const SizedBox(height: 10),
                    _hasCarRow(provider),
                    const SizedBox(height: 10),
                    _drivingRow(context, provider),
                    const SizedBox(height: 10),
                    _vehicleRow(context, provider),
                    const SizedBox(height: AppSpacing.x20),
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: provider.allComplete
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VerifiedSuccessScreen(),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress(VerificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.completedCount} of ${provider.totalCount} complete',
                style: AppTextStyles.labelM,
              ),
              Text(
                provider.timeRemaining,
                style: AppTextStyles.labelM
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                      width: constraints.maxWidth * provider.progress,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: AppRadius.pill,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- rows

  Widget _photoIdRow(BuildContext context, VerificationProvider provider) {
    final done = provider.photoId == VerificationStatus.done;
    return _CheckRow(
      icon: Icons.person,
      title: 'Photo ID and Proof',
      subtitle: done ? 'Driver license scanned' : "Scan your driver's license",
      status: provider.photoId,
      trailing: done
          ? const AppBadge(label: 'Done', showDot: false)
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScanPhotoIdScreen()),
      ),
    );
  }

  Widget _backgroundRow(BuildContext context, VerificationProvider provider) {
    final status = provider.backgroundCheck;
    return _CheckRow(
      icon: Icons.verified_user_outlined,
      title: 'Background check',
      subtitle: switch (status) {
        VerificationStatus.pending => 'Takes about 2 minutes',
        VerificationStatus.inReview => 'Usually ready in 24 hours',
        VerificationStatus.done => 'Cleared',
      },
      status: status,
      trailing: switch (status) {
        VerificationStatus.pending =>
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        VerificationStatus.inReview =>
          const AppBadge(label: 'In review', tone: AppBadgeTone.dark),
        VerificationStatus.done =>
          const AppBadge(label: 'Done', showDot: false),
      },
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => status == VerificationStatus.pending
              ? const BackgroundCheckScreen()
              : const BackgroundCheckStatusScreen(),
        ),
      ),
    );
  }

  Widget _drivingRow(BuildContext context, VerificationProvider provider) {
    final done = provider.drivingRecord == VerificationStatus.done;
    return _CheckRow(
      icon: Icons.directions_car,
      title: 'Driving record',
      subtitle: done ? 'Clean record confirmed' : 'Authorize a DMV check',
      status: provider.drivingRecord,
      trailing: done
          ? const AppBadge(label: 'Done', showDot: false)
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DrivingRecordScreen()),
      ),
    );
  }

  Widget _vehicleRow(BuildContext context, VerificationProvider provider) {
    final done = provider.vehicle == VerificationStatus.done;
    return _CheckRow(
      icon: done ? Icons.directions_car : Icons.lock_outline,
      title: 'Vehicle',
      subtitle: done
          ? '${provider.vehicleModel} · ${provider.vehiclePlate}'
          : 'Add plate, model & policy',
      status: provider.vehicle,
      trailing: done
          ? const AppBadge(label: 'Done', showDot: false)
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VehicleDetailsScreen()),
      ),
    );
  }

  /// The pill row that sits between the background check and driving record.
  Widget _hasCarRow(VerificationProvider provider) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.x16,
        right: AppSpacing.x12,
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, size: 22, color: AppColors.ink),
          const SizedBox(width: AppSpacing.x12),
          Expanded(
            child:
                Text('I have a car, I can help', style: AppTextStyles.labelM),
          ),
          AppToggle(value: provider.hasCar, onChanged: provider.setHasCar),
        ],
      ),
    );
  }
}

/// One checklist card: icon circle, title + subtitle, trailing badge/chevron.
class _CheckRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VerificationStatus status;
  final Widget trailing;
  final VoidCallback onTap;

  const _CheckRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.trailing,
    required this.onTap,
  });

  Color get _circleBackground => switch (status) {
        VerificationStatus.done => AppColors.lime,
        VerificationStatus.inReview => AppColors.ink,
        VerificationStatus.pending => AppColors.bgScreen,
      };

  Color get _circleForeground =>
      status == VerificationStatus.inReview ? AppColors.lime : AppColors.ink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgAll,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _circleBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: _circleForeground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelL),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x8),
            trailing,
          ],
        ),
      ),
    );
  }
}
