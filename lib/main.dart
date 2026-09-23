import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Asynchronous background warmup to wake up cloud backend container
  ApiService.warmupBackend();
  runApp(const DishaSaathiApp());
}

/// Disha Saathi (Disha Saathi) — AI-Driven Voice Assistant for Livelihood
/// Mapping and NSQF-Aligned Skilling Recommendations for SC Communities
/// under the GIA component of PM-AJAY.
///
/// SIH 2026 · Problem Statement 26097 · Team: The AI Alchemists
class DishaSaathiApp extends StatelessWidget {
  const DishaSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Disha Saathi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
