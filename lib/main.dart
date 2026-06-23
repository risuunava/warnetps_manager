import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'services/router.dart';
import 'services/unit_service.dart';
import 'services/tariff_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run default data initialization in background — don't block app startup
  _initializeDefaults();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Initializes default Firestore data asynchronously (non-blocking).
/// App startup will not wait for this to complete.
Future<void> _initializeDefaults() async {
  try {
    final tariffService = TariffService();
    final unitService = UnitService();
    await tariffService.initializeDefaultTariffs();
    await unitService.initializeDefaultUnits();
    debugPrint('Default tariffs and units initialized successfully.');
  } catch (e) {
    debugPrint('Error initializing defaults on start: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WarnetPS Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}