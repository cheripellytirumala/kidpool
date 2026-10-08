import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/us_phone.dart';
import '../../models/app_version_model.dart';
import 'supabase_guard.dart';

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

  /// True when the signed-in account already existed and has a role.
  Future<bool> isRegistered();
}

/// Phone sign-in through the `request-otp` / `verify-otp` edge functions;
/// the session they return is handed to the Supabase client so table
/// queries run as the signed-in user.
@LazySingleton(as: AppRemoteDataSource)
class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final SupabaseClient supabase;

  AppRemoteDataSourceImpl({required this.supabase});

  /// From the last successful verify-otp call; kept in memory only.
  bool _isNewUser = true;
  String? _role;

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
    final json = await _invoke(ApiConstants.requestOtpFunction, {
      'phone': _toE164(countryCode, phoneNumber),
    });
    // Only present while the function runs in demo mode (no SMS provider).
    if (json['otp'] case final String otp) {
      AppLogger.w('[DEMO OTP] Code: $otp (valid 5 min)');
    }
    return true;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    final json = await _invoke(ApiConstants.verifyOtpFunction, {
      'phone': _toE164(countryCode, phoneNumber),
      'otp': otp,
    });
    final refreshToken = (json['session'] as Map?)?['refreshToken'];
    if (json['status'] != 'verified' || refreshToken is! String) {
      throw ServerException(message: 'Wrong code entered. Please try again.');
    }
    await guardSupabase(() => supabase.auth.setSession(refreshToken));
    _isNewUser = json['isNewUser'] as bool? ?? true;
    _role = json['role'] as String?;
    return true;
  }

  @override
  Future<bool> isRegistered() async =>
      supabase.auth.currentUser != null && !_isNewUser && _role != null;

  Future<Map<String, dynamic>> _invoke(
    String function,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await supabase.functions.invoke(function, body: body);
      AppLogger.d('[API] $function → ${response.status}');
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionsFetchException {
      throw NetworkException('No internet connection');
    } on FunctionException catch (e) {
      AppLogger.d('[API] $function → ${e.status} ${e.details}');
      final details = e.details is Map ? e.details as Map : const {};
      throw ServerException(message: _messageFor(details));
    } on SocketException {
      throw NetworkException('No internet connection');
    }
  }

  static String _messageFor(Map details) {
    switch (details['error']) {
      case 'invalid_phone':
        return 'Enter a valid US phone number';
      case 'resend_too_soon':
        final wait = details['retryAfter'];
        return wait == null
            ? 'Please wait before requesting a new code.'
            : 'Please wait $wait seconds before requesting a new code.';
      case 'sms_not_configured':
        return "We can't send text messages right now. Please try again later.";
      case 'invalid_otp_format':
        return 'Enter the 6-digit code.';
      case 'invalid_otp':
        return 'Wrong code entered. Please try again.';
      case 'otp_not_found':
      case 'otp_expired':
        return 'Code expired. Please request a new one.';
      case 'too_many_attempts':
        return 'Too many wrong attempts. Please request a new code.';
      default:
        return 'Something went wrong. Please try again.';
    }
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
