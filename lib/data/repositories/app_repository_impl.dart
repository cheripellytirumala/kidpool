import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../data_sources/remote/app_remote_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final AppRemoteDataSource remoteDataSource;

  AppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppVersionEntity>> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  }) async {
    try {
      final model = await remoteDataSource.getAppVersion(
        roleId: roleId,
        device: device,
        versionNumber: versionNumber,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
