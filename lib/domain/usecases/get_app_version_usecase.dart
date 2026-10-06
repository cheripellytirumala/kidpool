import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/app_version_entity.dart';
import '../repositories/app_repository.dart';

class GetAppVersionUsecase {
  final AppRepository repository;

  GetAppVersionUsecase(this.repository);

  Future<Either<Failure, AppVersionEntity>> call(GetAppVersionParams params) async {
    return await repository.getAppVersion(
      device: params.device,
      versionNumber: params.versionNumber,
    );
  }
}

class GetAppVersionParams {
  final String device;
  final String versionNumber;

  GetAppVersionParams({
    required this.device,
    required this.versionNumber,
  });
}
