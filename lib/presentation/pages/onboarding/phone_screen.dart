import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/us_phone.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/primary_button.dart';
import 'verify_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndSend() async {
    final phone = _phoneController.text;
    final error = UsPhone.validate(phone);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() => _errorText = null);

    final provider = context.read<AppProvider>();
    final success = await provider.sendOtp(
      phoneNumber: phone,
      countryCode: UsPhone.countryCode,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyScreen(
            phoneNumber: phone,
            countryCode: UsPhone.countryCode,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Failed to send OTP')),
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
              Text(
                'What\'s your\nphone number?',
                style: AppTextStyles.headingH1,
              ),
              const SizedBox(height: AppSpacing.x12),
              Text(
                'We\'ll text you a code to sign in. No passwords to remember.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.x32),
              AppInput(
                controller: _phoneController,
                icon: Icons.phone,
                hintText: '(415) 555-0142',
                keyboardType: TextInputType.number,
                inputFormatters: [UsPhoneInputFormatter()],
                errorText: _errorText,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                // US numbers only, so the country code is fixed.
                leading: Text(
                  '🇺🇸 ${UsPhone.countryCode}',
                  style: AppTextStyles.bodyL,
                ),
              ),
              const SizedBox(height: AppSpacing.x24),
              // "Reassure every step" — calm status copy on a soft card.
              Container(
                padding: const EdgeInsets.all(AppSpacing.x16),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: AppColors.lime,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x16),
                    Expanded(
                      child: Text(
                        'Your number stays private. Parents only see your first name until you approve a ride.',
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: provider.isLoading ? 'Sending...' : 'Send code',
                    onPressed: provider.isLoading ? null : _validateAndSend,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.x16),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          ),
        ),
      ),
    );
  }
}
