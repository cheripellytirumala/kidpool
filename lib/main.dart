import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/app_provider.dart';

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
      ],
      child: MaterialApp(
        title: 'Clean Architecture Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AppVersionScreen(),
      ),
    );
  }
}

class AppVersionScreen extends StatefulWidget {
  const AppVersionScreen({super.key});

  @override
  State<AppVersionScreen> createState() => _AppVersionScreenState();
}

class _AppVersionScreenState extends State<AppVersionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().fetchAppVersion(
          roleId: 1,
          device: 'ios',
          versionNumber: '2.0',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Version Info')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          if (provider.appVersion == null) {
            return const Center(child: Text('No data found'));
          }

          final version = provider.appVersion!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Version: ${version.version}', style: Theme.of(context).textTheme.headlineSmall),
              Text('API Base URL: ${version.apiBaseUrl}'),
              Text('App Link: ${version.appLink}'),
              Text('Payment Message: ${version.paymentMessage}'),
              const Divider(),
              const Text('Distance Radius Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...version.distanceRadiusFilters.map((e) => ListTile(
                    title: Text('${e.radius} km'),
                  )),
            ],
          );
        },
      ),
    );
  }
}
