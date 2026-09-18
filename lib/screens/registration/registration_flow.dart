import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';
import 'step1_personal_info.dart';
import 'step2_education.dart';
import 'step3_livelihood.dart';
import 'step4_skills.dart';

/// Wraps the 4-step registration form (Personal Info -> Education ->
/// Livelihood -> Skills) with the shared top progress bar shown in the
/// mockups ("STEP X OF 4").
class RegistrationFlow extends StatelessWidget {
  const RegistrationFlow({super.key});

  static const _titles = ['Personal Info', 'Education', 'Livelihood', 'Skills'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final step = state.registrationStep;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(4, (i) {
                      final active = i <= step;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.tealLight : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('STEP ${step + 1} OF 4',
                      style: const TextStyle(color: AppColors.tealLight, fontWeight: FontWeight.w700, fontSize: 12.5, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(_titles[step], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: step,
                children: const [
                  Step1PersonalInfo(),
                  Step2Education(),
                  Step3Livelihood(),
                  Step4Skills(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> finish(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await state.completeRegistration();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Could not save profile. Is the backend running?'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

