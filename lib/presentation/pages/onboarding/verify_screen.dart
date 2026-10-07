import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/fill_scroll_view.dart';
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
  bool _resending = false;

  bool get _canResend => _secondsRemaining == 0 && !_resending;

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
      setState(() => _secondsRemaining--);
      // At 0 the countdown just stops; a new code is only sent when the user
      // taps "Resend code".
      if (_secondsRemaining <= 0) timer.cancel();
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    setState(() => _resending = true);
    final provider = context.read<AppProvider>();
    final sent = await provider.sendOtp(
      phoneNumber: widget.phoneNumber ?? '',
      countryCode: widget.countryCode ?? '',
    );
    if (!mounted) return;
    setState(() => _resending = false);
    if (sent) {
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code is on its way')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Failed to resend')),
      );
    }
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
          child: FillScrollView(
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
              // Boxes share the row's width so all six fit on narrow phones.
              Row(
                children: List.generate(6, (index) {
                  final box = Container(
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
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : AppSpacing.x8,
                      ),
                      child: box,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.x24),
              // Counts down, then becomes a tappable "Resend code".
              GestureDetector(
                onTap: _canResend ? _resendCode : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.x8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: _canResend
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.x8),
                      Text(
                        _resending
                            ? 'Sending…'
                            : _secondsRemaining > 0
                                ? 'Resend code in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                                : 'Resend code',
                        style: AppTextStyles.labelS.copyWith(
                          color: _canResend
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          decoration: _canResend
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
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
          )),
        ),
      ),
    );
  }
}
