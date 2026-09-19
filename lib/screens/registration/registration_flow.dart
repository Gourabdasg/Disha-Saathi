import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';
import 'step1_personal_info.dart';

/// Account registration screen for PM-AJAY SC Beneficiaries.
/// Requirement 1 & 4: Streamlined single-step Account Creation flow.
class RegistrationFlow extends StatelessWidget {
  const RegistrationFlow({super.key});

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  const Text('PM-AJAY GIA · SCHEME REGISTRATION',
                      style: TextStyle(color: AppColors.tealLight, fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Enter your details and upload your SC Caste Certificate',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const Expanded(
              child: Step1PersonalInfo(),
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
          content: Text(state.errorMessage ?? 'Account created and saved.'),
          backgroundColor: AppColors.teal,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }
}
