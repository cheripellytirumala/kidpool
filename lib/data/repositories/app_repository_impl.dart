import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../data_sources/remote/app_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppRepository)
class AppRepositoryImpl implements AppRepository {
  final AppRemoteDataSource remoteDataSource;

  AppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppVersionEntity>> getAppVersion({
    required String device,
    required String versionNumber,
  }) async {
    try {
      final model = await remoteDataSource.getAppVersion(
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

  @override
  Future<Either<Failure, bool>> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      final result = await remoteDataSource.sendOtp(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        otp: otp,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
