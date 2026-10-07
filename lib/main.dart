import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/verification_provider.dart';
import 'presentation/pages/onboarding/splash_screen.dart';
import 'presentation/pages/onboarding/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AppProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<OnboardingProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<VerificationProvider>(),
        ),
      ],
      child: MaterialApp(
        title: 'Kidpool',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashNavigator(),
      ),
    );
  }
}

class SplashNavigator extends StatefulWidget {
  const SplashNavigator({super.key});

  @override
  State<SplashNavigator> createState() => _SplashNavigatorState();
}

class _SplashNavigatorState extends State<SplashNavigator> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Check the app version while the splash shows for 2 seconds.
    await Future.wait([
      _checkAppVersion(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  Future<void> _checkAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    final device =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    await context.read<AppProvider>().fetchAppVersion(
          device: device,
          versionNumber: info.version,
        );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
