import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env_config.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/us_phone.dart';
import '../../models/app_version_model.dart';
import '../local/dev_otp_service.dart';
import 'supabase_guard.dart';
import 'package:injectable/injectable.dart';
import '../../../core/di/app_environment.dart';

abstract class AppRemoteDataSource {
  Future<AppVersionModel> getAppVersion({
    required String device,
    required String versionNumber,
  });

  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  });

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  });
}

@LazySingleton(as: AppRemoteDataSource, env: [AppEnvironment.supabase])
class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final SupabaseClient supabase;
  final DevOtpService devOtp;

  AppRemoteDataSourceImpl({required this.supabase, required this.devOtp});

  @override
  Future<AppVersionModel> getAppVersion({
    required String device,
    required String versionNumber,
  }) async {
    final result = await guardSupabase(() => supabase.rpc(
          ApiConstants.checkAppVersionRpc,
          params: {'platform': device, 'appVersion': versionNumber},
        ));
    AppLogger.d('[API] check_app_version($device, $versionNumber) → $result');

    try {
      return AppVersionModel.fromJson(
        Map<String, dynamic>.from(result as Map),
        platform: device,
      );
    } catch (e) {
      throw ParsingException('Failed to parse app version response');
    }
  }

  @override
  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final phone = _toE164(countryCode, phoneNumber);
    if (EnvConfig.useDevOtp) {
      devOtp.send(phone);
      return true;
    }
    await guardSupabase(() => supabase.auth.signInWithOtp(phone: phone));
    return true;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    if (EnvConfig.useDevOtp) {
      devOtp.verify(_toE164(countryCode, phoneNumber), otp);
      // Onboarding writes rows owned by the current user, so dev needs a real
      // session. Requires Anonymous sign-ins to be enabled in Supabase Auth.
      if (supabase.auth.currentSession == null) {
        try {
          await supabase.auth.signInAnonymously();
        } on AuthException catch (e) {
          throw ServerException(
              message: 'Dev sign-in failed: ${e.message}. Enable Anonymous '
                  'sign-ins in Supabase → Authentication → Sign In / Providers.');
        }
      }
      return true;
    }
    final response = await guardSupabase(() => supabase.auth.verifyOTP(
          phone: _toE164(countryCode, phoneNumber),
          token: otp,
          type: OtpType.sms,
        ));
    if (response.session == null) {
      throw ServerException(message: 'Wrong code entered. Please try again.');
    }
    return true;
  }

  // Only US numbers are supported.
  String _toE164(String countryCode, String phoneNumber) {
    if (countryCode != UsPhone.countryCode ||
        UsPhone.validate(phoneNumber) != null) {
      throw ServerException(message: 'Enter a valid US phone number');
    }
    return UsPhone.toE164(phoneNumber);
  }
}
