import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-restore persistent authenticated session if app reopens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<AppState>();
      await state.checkAndRestoreSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startInteraction() async {
    _pulseController.stop();
    final state = context.read<AppState>();
    final hasActiveSession = await state.checkAndRestoreSession();

    if (!mounted) return;
    if (hasActiveSession && state.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
      );
    }
  }

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
                const Text(
                  'PM-AJAY · GIA COMPONENT',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
                const Spacer(flex: 3),

                // Requirement 3: Animated "Click to Start" Callout & Pulsing Microphone
                Column(
                  children: [
                    // Floating "Click to Start" Callout
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -2 * _pulseController.value),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.touch_app_rounded, size: 16, color: AppColors.navy),
                            SizedBox(width: 6),
                            Text(
                              'Click to Start',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Requirement 2 & 4 & 5: Interactive Central Microphone with Soft Pulsing Ripple
                    GestureDetector(
                      onTap: _startInteraction,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing outer ripple
                              Container(
                                width: 110 * _scaleAnimation.value,
                                height: 110 * _scaleAnimation.value,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(_opacityAnimation.value * 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              child!,
                            ],
                          );
                        },
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          ),
                          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 52),
                        ),
                      ),
                    ),
                  ],
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
                const Spacer(flex: 5),

                const Text(
                  'Ministry of Social Justice & Empowerment, GoI',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 24),
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
