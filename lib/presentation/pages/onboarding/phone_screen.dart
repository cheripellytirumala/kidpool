import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../widgets/primary_button.dart';
import 'verify_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+1';
  String? _errorText;

  final List<Map<String, String>> _countries = [
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
  ];

  void _validateAndSend() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorText = 'Please enter your phone number');
      return;
    }
    if (phone.length < 7) {
      setState(() => _errorText = 'Please enter a valid phone number');
      return;
    }

    setState(() => _errorText = null);

    final provider = context.read<AppProvider>();
    final success = await provider.sendOtp(
      phoneNumber: phone,
      countryCode: _selectedCountryCode,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyScreen(
            phoneNumber: phone,
            countryCode: _selectedCountryCode,
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
                'What\'s your\nphone number?',
                style: AppTextStyles.headingH1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'We\'ll text you a code to sign in. No passwords to remember.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: AppColors.ink, size: 20),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedCountryCode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedCountryCode = newValue);
                        }
                      },
                      items: _countries.map<DropdownMenuItem<String>>(
                          (Map<String, String> country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Text('${country['flag']} ${country['code']}',
                              style: AppTextStyles.bodyL),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '(415) 555-0142',
                          hintStyle: AppTextStyles.bodyL
                              .copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          errorText: _errorText,
                        ),
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.bodyL,
                        onChanged: (_) {
                          if (_errorText != null)
                            setState(() => _errorText = null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.ink,
                      child: Icon(Icons.lock, color: AppColors.lime, size: 18),
                    ),
                    const SizedBox(width: 16),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
