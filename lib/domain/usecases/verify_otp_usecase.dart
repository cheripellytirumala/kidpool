import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/app_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VerifyOtpUsecase {
  final AppRepository repository;

  VerifyOtpUsecase(this.repository);

  Future<Either<Failure, bool>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      phoneNumber: params.phoneNumber,
      countryCode: params.countryCode,
      otp: params.otp,
    );
  }
}

class VerifyOtpParams {
  final String phoneNumber;
  final String countryCode;
  final String otp;

  VerifyOtpParams({
    required this.phoneNumber,
    required this.countryCode,
    required this.otp,
  });
}
