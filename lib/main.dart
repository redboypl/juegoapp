// ============================================================
// main.dart — Punto de entrada de la app
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/start_screen.dart';
import 'services/audio_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa el servicio de audio global (carga prefs de volumen/mute)
  // antes de levantar la UI, para que el primer frame ya tenga el estado
  // correcto si el usuario abre los ajustes de inmediato.
  await AudioService.instance.init();

  runApp(const TriviaApp());
}

class TriviaApp extends StatefulWidget {
  const TriviaApp({super.key});

  @override
  State<TriviaApp> createState() => _TriviaAppState();
}

class _TriviaAppState extends State<TriviaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Arranca la música de fondo una vez montado el primer frame.
    AudioService.instance.ensurePlaying();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Beisbolera Venezuela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.rojoVenezolano,
          secondary: AppColors.acentoDorado,
          surface: AppColors.fondoOscuro,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.fondoOscuro,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const StartScreen(),
    );
  }
}
