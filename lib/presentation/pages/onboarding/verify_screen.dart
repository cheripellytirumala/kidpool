import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
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
          backgroundColor: Colors.redAccent,
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
                'Enter the\n6-digit code',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Sent to ${widget.countryCode ?? ''} ${widget.phoneNumber ?? ''}',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onChanged(value, index),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: AppTextStyles.headingH2,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.refresh,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
