import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/app_version_model.dart';
import 'supabase_guard.dart';

abstract class AppRemoteDataSource {
  Future<AppVersionModel> getAppVersion({required String device});

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

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final SupabaseClient supabase;

  AppRemoteDataSourceImpl({required this.supabase});

  @override
  Future<AppVersionModel> getAppVersion({required String device}) async {
    final Map<String, dynamic>? row = await guardSupabase(() => supabase
        .from(ApiConstants.appVersionsTable)
        .select()
        .eq(ApiConstants.platform, device)
        .maybeSingle());

    if (row == null) {
      throw ServerException(message: 'No version info for $device');
    }
    try {
      return AppVersionModel.fromJson(row);
    } catch (e) {
      throw ParsingException('Failed to parse app version response');
    }
  }

  @override
  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    await guardSupabase(() => supabase.auth.signInWithOtp(
          phone: _toE164(countryCode, phoneNumber),
        ));
    return true;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
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

  String _toE164(String countryCode, String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.replaceAll(RegExp(r'\D'), '');
    return '+$code$digits';
  }
}
