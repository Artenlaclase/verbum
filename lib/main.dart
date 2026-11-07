import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/database/platform_init.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de SQLite para la plataforma activa (FFI desktop, Web o móvil)
  initPlatformDatabase();

  // Inicialización de Firebase con fallback seguro
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Aviso Firebase: No inicializado o credenciales pendientes ($e)');
  }

  runApp(
    const ProviderScope(
      child: VerbumApp(),
    ),
  );
}

class VerbumApp extends ConsumerWidget {
  const VerbumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeStateProvider);

    return MaterialApp(
      title: 'Verbum — Sagrada Escritura y Liturgia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
