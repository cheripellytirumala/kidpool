import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/app_version_model.dart';

abstract class AppRemoteDataSource {
  Future<AppVersionModel> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  });

  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  });

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
}

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final ApiClient apiClient;
  static String? _lastGeneratedOtp;

  AppRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AppVersionModel> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  }) async {
    final response = await apiClient.post(
      ApiConstants.getAppVersion,
      queryParameters: {
        ApiConstants.roleId: roleId,
        ApiConstants.device: device,
        ApiConstants.versionNumber: versionNumber,
      },
    );

    if (response.data != null) {
      try {
        return AppVersionModel.fromJson(response.data);
      } catch (e) {
        throw ParsingException('Failed to parse app version response');
      }
    } else {
      throw ServerException(message: 'Empty response from server');
    }
  }

  @override
  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    // Generate a 6-digit verification code locally
    final String otp = _generateOtp();
    _lastGeneratedOtp = otp;

    if (kDebugMode) {
      print('-----------------------------------------');
      print(
          'LOCAL DEV: Verification code for $countryCode$phoneNumber is: $otp');
      print('-----------------------------------------');
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return true;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_lastGeneratedOtp != null && _lastGeneratedOtp == otp) {
      return true;
    } else {
      throw ServerException(message: 'Wrong code entered. Please try again.');
    }
  }

  String _generateOtp() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }
}
