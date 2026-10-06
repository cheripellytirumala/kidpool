import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/app_repository.dart';

class SendOtpUsecase {
  final AppRepository repository;

  SendOtpUsecase(this.repository);

  Future<Either<Failure, bool>> call(SendOtpParams params) {
    return repository.sendOtp(
      phoneNumber: params.phoneNumber,
      countryCode: params.countryCode,
    );
  }
}

class SendOtpParams {
  final String phoneNumber;
  final String countryCode;

  SendOtpParams({
    required this.phoneNumber,
    required this.countryCode,
  });
}
