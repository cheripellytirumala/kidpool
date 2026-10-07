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

  /// True when the signed-in account has finished onboarding (it belongs to
  /// a circle, the last onboarding step).
  Future<bool> isRegistered();
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
      final phone = _toE164(countryCode, phoneNumber);
      devOtp.verify(phone, otp);
      await _devSignIn(phone);
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

  /// Dev stand-in for phone auth: an anonymous account tagged with the
  /// number (user metadata `dev_phone`), so the same number keeps landing in
  /// the same account on this device and a different number gets a new one.
  /// An untagged session (from before tagging existed) is claimed by the
  /// first number verified on it. Requires Anonymous sign-ins in Supabase.
  Future<void> _devSignIn(String phone) async {
    try {
      final user = supabase.auth.currentUser;
      final tagged = user?.userMetadata?[_devPhoneKey] as String?;
      if (user != null && tagged == phone) return;
      if (user != null && tagged == null) {
        await supabase.auth
            .updateUser(UserAttributes(data: {_devPhoneKey: phone}));
        return;
      }
      if (user != null) await supabase.auth.signOut();
      await supabase.auth.signInAnonymously(data: {_devPhoneKey: phone});
    } on AuthException catch (e) {
      throw ServerException(
          message: 'Dev sign-in failed: ${e.message}. Enable Anonymous '
              'sign-ins in Supabase → Authentication → Sign In / Providers.');
    }
  }

  static const String _devPhoneKey = 'dev_phone';

  @override
  Future<bool> isRegistered() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final rows = await guardSupabase(() => supabase
        .from(ApiConstants.circleMembersTable)
        .select('circle_id')
        .eq('user_id', userId)
        .limit(1));
    return rows.isNotEmpty;
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
