import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../data/data_sources/remote/app_remote_data_source.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/repositories/app_repository.dart';
import '../../domain/usecases/get_app_version_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../presentation/providers/app_provider.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Provider
  sl.registerFactory(() => AppProvider(
        getAppVersionUsecase: sl(),
        sendOtpUsecase: sl(),
        verifyOtpUsecase: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => GetAppVersionUsecase(sl()));
  sl.registerLazySingleton(() => SendOtpUsecase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(sl()));

  // Repositories
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AppRemoteDataSource>(
    () => AppRemoteDataSourceImpl(apiClient: sl()),
  );

  // Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton<Dio>(() => DioClient.getDio());
}
