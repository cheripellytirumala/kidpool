import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_version_entity.dart';

abstract class AppRepository {
  Future<Either<Failure, AppVersionEntity>> getAppVersion({
    required String device,
    required String versionNumber,
  });

  Future<Either<Failure, bool>> sendOtp({
    required String phoneNumber,
    required String countryCode,
  });

  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  });

  /// Whether the signed-in account has already finished onboarding.
  Future<Either<Failure, bool>> isRegistered();
}
