import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  final bool embedded;
  const ProgressScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final steps = state.journeySteps;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!embedded)
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  const Text('SKILL JOURNEY', style: TextStyle(color: AppColors.tealLight, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  const Text('My Progress', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: profile.journeyPercent / 100,
                              strokeWidth: 6,
                              backgroundColor: Colors.white24,
                              color: AppColors.tealLight,
                            ),
                            Center(
                              child: Text('${profile.journeyPercent}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                            const Text('Journey in progress · Keep going!', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TagBadge(label: '4/7 Steps', color: Colors.white.withOpacity(0.15)),
                                const SizedBox(width: 8),
                                const TagBadge(label: 'On Track', color: AppColors.tealLight),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Skill Journey', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 18),
                        for (int i = 0; i < steps.length; i++) _journeyTile(steps[i], isLast: i == steps.length - 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _achievement('⭐', 'Profile Completed', 'Aug 10'),
                      const SizedBox(width: 12),
                      _achievement('🗺️', 'Livelihood Mapped', 'Aug 11'),
                      const SizedBox(width: 12),
                      _achievement('🤖', 'AI Analyzed', 'Aug 12'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _stat('18', 'Days Active'),
                      const SizedBox(width: 12),
                      _stat('8', 'Skills Found'),
                      const SizedBox(width: 12),
                      _stat('3', 'Courses Saved'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journeyTile(JourneyStep step, {required bool isLast}) {
    Color circleColor;
    Widget icon;
    switch (step.state) {
      case JourneyStepState.completed:
        circleColor = AppColors.success;
        icon = const Icon(Icons.check, color: Colors.white, size: 18);
        break;
      case JourneyStepState.active:
        circleColor = AppColors.navy;
        icon = Icon(iconFor(step.icon), color: Colors.white, size: 16);
        break;
      case JourneyStepState.locked:
        circleColor = Colors.grey.shade300;
        icon = Icon(iconFor(step.icon), color: Colors.grey.shade500, size: 16);
        break;
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: Center(child: icon),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: step.state == JourneyStepState.locked ? Colors.grey.shade200 : AppColors.success.withOpacity(0.4))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: step.state == JourneyStepState.locked ? AppColors.textMuted : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(step.subtitle,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: step.state == JourneyStepState.active ? AppColors.navy : AppColors.textMuted,
                          fontWeight: step.state == JourneyStepState.active ? FontWeight.w600 : FontWeight.w400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievement(String emoji, String title, String date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
