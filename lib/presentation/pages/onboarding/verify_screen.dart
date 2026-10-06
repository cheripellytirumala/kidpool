import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/primary_button.dart';
import 'choose_user_type_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? countryCode;

  const VerifyScreen({
    super.key,
    this.phoneNumber,
    this.countryCode,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _resendCode();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    final provider = context.read<AppProvider>();
    await provider.sendOtp(
      phoneNumber: widget.phoneNumber ?? '',
      countryCode: widget.countryCode ?? '',
    );
    _startTimer();
  }

  void _handleVerify() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code')),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final success = await provider.verifyOtp(
      phoneNumber: widget.phoneNumber ?? '',
      countryCode: widget.countryCode ?? '',
      otp: otp,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChooseUserTypeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Wrong code entered'),
          backgroundColor: AppColors.statusSos,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
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
              Text('Enter the\n6-digit code', style: AppTextStyles.headingH1),
              const SizedBox(height: AppSpacing.x12),
              Text(
                'Sent to ${widget.countryCode ?? ''} ${widget.phoneNumber ?? ''}',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.x32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onChanged(value, index),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      cursorColor: AppColors.ink,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTextStyles.headingH2,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.x24),
              Row(
                children: [
                  const Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.x8),
                  Text(
                    'Resend code in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelS
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: provider.isLoading
                        ? 'Verifying...'
                        : 'Verify & continue',
                    onPressed: provider.isLoading ? null : _handleVerify,
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
}
