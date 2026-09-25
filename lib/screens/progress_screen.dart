import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  final bool embedded;
  const ProgressScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final steps = [
      const JourneyStep('Registration', 'Completed', JourneyStepState.completed, 'person'),
      JourneyStep(
        'Livelihood Assessment',
        profile.calculateCompletionPercent() >= 100 ? 'Completed' : '${profile.calculateCompletionPercent()}% Complete',
        profile.calculateCompletionPercent() >= 100 ? JourneyStepState.completed : JourneyStepState.active,
        'chat',
      ),
      JourneyStep(
        'Skill Recommendation',
        profile.calculateCompletionPercent() >= 100 ? 'Matched NSQF Courses' : 'In progress',
        profile.calculateCompletionPercent() >= 100 ? JourneyStepState.completed : JourneyStepState.active,
        'school',
      ),
      const JourneyStep('PM-AJAY Certification', 'In progress', JourneyStepState.active, 'medal'),
    ];

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
                  Text(state.tr('skill_journey'), style: const TextStyle(color: AppColors.tealLight, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  Text(state.tr('my_progress'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
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
                            Text(profile.name.isNotEmpty ? profile.name : 'Beneficiary',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(state.tr('journey_in_progress'), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _pillTag('4/7 Steps', Colors.white24, Colors.white),
                                const SizedBox(width: 8),
                                _pillTag('On Track', AppColors.tealLight, Colors.white),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.tr('your_skill_journey'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ...List.generate(steps.length, (i) => _stepTile(steps[i], i == steps.length - 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillTag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _stepTile(JourneyStep step, bool isLast) {
    final isDone = step.state == JourneyStepState.completed;
    final isActive = step.state == JourneyStepState.active;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.success : (isActive ? AppColors.navy : Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconData(step.icon), size: 18, color: isDone || isActive ? Colors.white : Colors.grey.shade600),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.success : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isActive ? AppColors.navy : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(step.subtitle, style: TextStyle(fontSize: 12, color: isActive ? AppColors.navy : AppColors.textMuted, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconData(String key) {
    switch (key) {
      case 'check':
        return Icons.check_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'medal':
        return Icons.military_tech_rounded;
      case 'certificate':
        return Icons.verified_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }
}
