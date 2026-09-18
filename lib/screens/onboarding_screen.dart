import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String desc;
  const _OnboardData(this.icon, this.title, this.subtitle, this.desc);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _OnboardData(
      Icons.record_voice_over_rounded,
      'Tell Us About Yourself',
      'अपने बारे में बताएं',
      'Share your education, work experience, and current livelihood. Our AI understands your unique story.',
    ),
    _OnboardData(
      Icons.insights_rounded,
      'Discover Your Skills',
      'अपने कौशल खोजें',
      'AI maps your existing skills and identifies gaps. Know exactly where you stand on the NSQF skill ladder.',
    ),
    _OnboardData(
      Icons.fact_check_rounded,
      'Find the Right Training',
      'सही प्रशिक्षण खोजें',
      'Get personalized NSQF-aligned training recommendations near you. Apply directly from the app.',
    ),
  ];

  void _finish() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(s.icon, size: 62, color: AppColors.teal),
                        ),
                        const SizedBox(height: 36),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        Text(s.subtitle, style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
                        const SizedBox(height: 16),
                        Text(s.desc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMuted)),
                      ],
                    ),
                  );
                },
              ),
            ),
            DotsIndicator(count: _slides.length, activeIndex: _page),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GradientButton(
                label: isLast ? 'Get Started · शुरू करें' : 'Next · अगला',
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
