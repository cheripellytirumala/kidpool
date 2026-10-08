import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

/// The app's service locator. Registrations are generated from annotations:
///
/// * `@injectable` — a new instance each time (view models / providers)
/// * `@lazySingleton` — one shared instance, built on first use (usecases)
/// * `@LazySingleton(as: Interface)` — binds an implementation to its
///   abstract type (repositories, data sources)
///
/// After adding or changing an annotated class, regenerate with:
/// `dart run build_runner build --delete-conflicting-outputs`
final sl = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  await sl.init();
}
