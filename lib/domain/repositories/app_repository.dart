import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/app_version_entity.dart';

abstract class AppRepository {
  Future<Either<Failure, AppVersionEntity>> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  });
}
