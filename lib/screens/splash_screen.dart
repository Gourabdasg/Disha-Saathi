import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    _iconChip(Icons.star_border_rounded),
                    const SizedBox(width: 12),
                    _iconChip(Icons.add_box_outlined),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('PM-AJAY · GIA COMPONENT',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const Spacer(flex: 3),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 28),
                const Text('दिशा साथी',
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Disha Saathi',
                    style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'AI-powered Livelihood & Skill Assistant for SC Communities',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.4)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                      );
                    },
                    child: const Text('Tap to Begin · शुरू करें',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Ministry of Social Justice & Empowerment, GoI',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconChip(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
