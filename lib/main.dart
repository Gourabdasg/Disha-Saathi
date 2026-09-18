import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DishaSaathiApp());
}

/// Disha Saathi (Disha Saathi) — AI-Driven Voice Assistant for Livelihood
/// Mapping and NSQF-Aligned Skilling Recommendations for SC Communities
/// under the GIA component of PM-AJAY.
///
/// SIH 2026 · Problem Statement 26097 · Team: The AI Alchemists
///
/// This Flutter client talks to:
///   - Node.js + Express backend (REST API, auth, profile, scheme data)
///   - Python + FastAPI + NLP AI/ML service (voice STT/TTS, skill matching)
///   - MongoDB (beneficiary + training data)
/// See /backend and /ai-service stubs in this repo for the reference API
/// contracts. This app currently runs against local mock data so the full
/// UI/UX flow can be demoed without a live backend.
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
