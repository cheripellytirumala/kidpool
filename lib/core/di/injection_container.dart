import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/data_sources/local/local_app_data_source.dart';
import '../../data/data_sources/local/local_onboarding_data_source.dart';
import '../../data/data_sources/remote/app_remote_data_source.dart';
import '../../data/data_sources/remote/onboarding_remote_data_source.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/app_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/get_app_version_usecase.dart';
import '../../domain/usecases/get_circles_usecase.dart';
import '../../domain/usecases/get_schools_usecase.dart';
import '../../domain/usecases/join_circle_usecase.dart';
import '../../domain/usecases/save_kids_usecase.dart';
import '../../domain/usecases/save_role_usecase.dart';
import '../../domain/usecases/start_circle_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../presentation/providers/app_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';
import '../config/env_config.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Provider
  sl.registerFactory(() => AppProvider(
        getAppVersionUsecase: sl(),
        sendOtpUsecase: sl(),
        verifyOtpUsecase: sl(),
      ));
  sl.registerFactory(() => OnboardingProvider(
        saveRoleUsecase: sl(),
        getSchoolsUsecase: sl(),
        saveKidsUsecase: sl(),
        getCirclesUsecase: sl(),
        joinCircleUsecase: sl(),
        startCircleUsecase: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => GetAppVersionUsecase(sl()));
  sl.registerLazySingleton(() => SendOtpUsecase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(sl()));
  sl.registerLazySingleton(() => SaveRoleUsecase(sl()));
  sl.registerLazySingleton(() => GetSchoolsUsecase(sl()));
  sl.registerLazySingleton(() => SaveKidsUsecase(sl()));
  sl.registerLazySingleton(() => GetCirclesUsecase(sl()));
  sl.registerLazySingleton(() => JoinCircleUsecase(sl()));
  sl.registerLazySingleton(() => StartCircleUsecase(sl()));

  // Repositories
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  if (!EnvConfig.useSupabase) {
    sl.registerLazySingleton<AppRemoteDataSource>(() => LocalAppDataSource());
    sl.registerLazySingleton<OnboardingRemoteDataSource>(
      () => LocalOnboardingDataSource(),
    );
    return;
  }

  sl.registerLazySingleton<AppRemoteDataSource>(
    () => AppRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(supabase: sl()),
  );

  // Core
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabasePublishableKey,
  );
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}
