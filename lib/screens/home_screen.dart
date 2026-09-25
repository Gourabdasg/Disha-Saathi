import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_icons_row.dart';
import 'ai_chat_screen.dart';
import 'notifications_screen.dart';
import 'profile_completion_screen.dart';
import 'progress_screen.dart';
import 'recommendations_screen.dart';
import 'training_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;

    final displayLocation = profile.location.isNotEmpty
        ? profile.location
        : (profile.district.isNotEmpty ? '${profile.district}, ${profile.state}' : 'Kolkata, West Bengal');

    final completionPercent = profile.calculateCompletionPercent();
    final journeyPercent = profile.calculateProgressPercent();
    final missing = profile.missingFields;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.tr('scheme_subtitle'),
                                  style: const TextStyle(color: AppColors.tealLight, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text('Hello, ${profile.name}',
                                        style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('👋', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Dynamic Location Display in App Header
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      displayLocation,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _iconButton(context, Icons.notifications_none_rounded, badge: true, onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                        }),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(profile.name.isNotEmpty ? profile.name[0] : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Requirement 8: Profile Completion Card
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Profile Completion – $completionPercent%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
                                  child: Text(completionPercent == 100 ? 'Complete ✓' : 'Complete Profile →', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completionPercent / 100.0,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                color: AppColors.tealLight,
                              ),
                            ),
                            if (missing.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Missing: ${missing.take(2).join(', ')}${missing.length > 2 ? ' +${missing.length - 2} more' : ''}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // AI Voice Assistant Card & Contact Row
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiChatScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.buttonGradient),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: Image.asset('assets/app_icon_512.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.tr('ai_voice_assistant'), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(state.tr('start_talking'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  const Text('Tell me about your work & skills', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 26),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Prefer another way to reach us?',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const ContactIconsRow(),
                    const SizedBox(height: 20),

                    // 2 x 2 Feature Grid Cards matching user screenshot
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: Livelihood Profile
                          Expanded(
                            child: _featureCard(
                              icon: Icons.agriculture_rounded,
                              iconColor: AppColors.success,
                              title: state.tr('livelihood_profile'),
                              subtitle: profile.livelihood.isNotEmpty ? profile.livelihood : 'Unemployed',
                              progress: 0.55,
                              progressColor: AppColors.navy,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Card 2: Skill Recommendations
                          Expanded(
                            child: _featureCard(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.warning,
                              title: state.tr('skill_recommendations'),
                              subtitle: '4 new matches found',
                              action: state.tr('view_all'),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecommendationsScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 3: Training Near You
                          Expanded(
                            child: _featureCard(
                              icon: Icons.school_rounded,
                              iconColor: AppColors.navy,
                              title: state.tr('training_near_you'),
                              subtitle: '12 courses available',
                              action: state.tr('view_all'),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Card 4: My Progress
                          Expanded(
                            child: _featureCard(
                              icon: Icons.show_chart_rounded,
                              iconColor: AppColors.orange,
                              title: state.tr('my_progress'),
                              subtitle: '${state.tr('my_progress')} – $journeyPercent%',
                              progress: journeyPercent / 100.0,
                              progressColor: AppColors.orange,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgressScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                    Text(state.tr('recent_activity'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _activityTile(Icons.check, AppColors.success, 'Profile setup completed', '2h ago'),
                          const Divider(height: 1),
                          _activityTile(Icons.smart_toy_rounded, AppColors.purple, 'AI analyzed your skills', 'Yesterday'),
                          const Divider(height: 1),
                          _activityTile(Icons.school_rounded, AppColors.textMuted, '3 training courses matched', '2d ago'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, {bool badge = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 20)),
            if (badge)
              Positioned(
                right: 9,
                top: 9,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    double? progress,
    Color progressColor = AppColors.navy,
    String? action,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 142),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textDark, height: 1.25),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (progress != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: progressColor,
                ),
              ),
            if (action != null)
              Row(
                children: [
                  Text(
                    action,
                    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(IconData icon, Color color, String title, String time) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
      trailing: Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
    );
  }
}
