import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/usecases/check_registered_usecase.dart';
import '../../domain/usecases/get_app_version_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppProvider extends ChangeNotifier {
  final GetAppVersionUsecase getAppVersionUsecase;
  final SendOtpUsecase sendOtpUsecase;
  final VerifyOtpUsecase verifyOtpUsecase;
  final CheckRegisteredUsecase checkRegisteredUsecase;

  AppProvider({
    required this.getAppVersionUsecase,
    required this.sendOtpUsecase,
    required this.verifyOtpUsecase,
    required this.checkRegisteredUsecase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppVersionEntity? _appVersion;
  AppVersionEntity? get appVersion => _appVersion;

  Future<void> fetchAppVersion({
    required String device,
    required String versionNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getAppVersionUsecase(
      GetAppVersionParams(
        device: device,
        versionNumber: versionNumber,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('[API] check_app_version failed: ${failure.message}');
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _appVersion = data;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await sendOtpUsecase(
      SendOtpParams(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyOtpUsecase(
      VerifyOtpParams(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        otp: otp,
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// After sign-in: true when this number's account already finished
  /// onboarding, false when it's new, null if the check failed
  /// ([errorMessage] says why).
  Future<bool?> checkRegistered() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await checkRegisteredUsecase();

    _isLoading = false;
    final registered = result.fold(
      (failure) {
        _errorMessage = failure.message;
        return null;
      },
      (registered) => registered,
    );
    notifyListeners();
    return registered;
  }
}
