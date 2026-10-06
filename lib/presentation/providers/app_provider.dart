import 'package:flutter/material.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/usecases/get_app_version_usecase.dart';

class AppProvider extends ChangeNotifier {
  final GetAppVersionUsecase getAppVersionUsecase;

  AppProvider({required this.getAppVersionUsecase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppVersionEntity? _appVersion;
  AppVersionEntity? get appVersion => _appVersion;

  Future<void> fetchAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getAppVersionUsecase(
      GetAppVersionParams(
        roleId: roleId,
        device: device,
        versionNumber: versionNumber,
      ),
    );

    result.fold(
      (failure) {
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
}
