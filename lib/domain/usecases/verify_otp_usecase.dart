import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/app_repository.dart';

class VerifyOtpUsecase {
  final AppRepository repository;

  VerifyOtpUsecase(this.repository);

  Future<Either<Failure, bool>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      phoneNumber: params.phoneNumber,
      otp: params.otp,
    );
  }
}

class VerifyOtpParams {
  final String phoneNumber;
  final String otp;

  VerifyOtpParams({
    required this.phoneNumber,
    required this.otp,
  });
}
