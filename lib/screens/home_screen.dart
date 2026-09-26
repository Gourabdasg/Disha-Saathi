import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_icons_row.dart';
import 'ai_chat_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'profile_completion_screen.dart';
import 'progress_screen.dart';
import 'recommendations_screen.dart';
import 'training_screen.dart';

/// Gentle, professional waving hand emoji 👋 animation widget
class WavingEmojiWidget extends StatefulWidget {
  const WavingEmojiWidget({super.key});

  @override
  State<WavingEmojiWidget> createState() => _WavingEmojiWidgetState();
}

class _WavingEmojiWidgetState extends State<WavingEmojiWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.10).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.10, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          origin: const Offset(8, 16),
          child: child,
        );
      },
      child: const Text(
        '👋',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

/// Subtle, professional pulsing/ripple glow animation widget around waveform icon
class VoiceWaveformPulseWidget extends StatefulWidget {
  const VoiceWaveformPulseWidget({super.key});

  @override
  State<VoiceWaveformPulseWidget> createState() => _VoiceWaveformPulseWidgetState();
}

class _VoiceWaveformPulseWidgetState extends State<VoiceWaveformPulseWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final rippleScale = 1.0 + (progress * 0.35);
        final rippleOpacity = (1.0 - progress).clamp(0.0, 0.6);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Pulsing Glow Ring
            Transform.scale(
              scale: rippleScale,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: rippleOpacity),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: rippleOpacity * 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Inner Circular Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ],
        );
      },
      child: const Icon(
        Icons.graphic_eq_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoDetectLocationIfNeeded();
    });
  }

  Future<void> _autoDetectLocationIfNeeded() async {
    final state = context.read<AppState>();
    final profile = state.profile;

    if (profile.location.isEmpty || profile.location.toLowerCase().contains('village')) {
      try {
        final res = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final city = data['city'] as String? ?? 'Kolkata';
          final region = data['regionName'] as String? ?? 'West Bengal';

          profile.district = city;
          profile.state = region;
          profile.location = '$city, $region';

          state.district = city;
          state.stateName = region;
          state.location = '$city, $region';

          await state.updateUserProfile(profile);
        }
      } catch (_) {}
    }
  }

  Widget _buildSmallAvatarWidget(UserProfile profile) {
    if (profile.photoUrl.isNotEmpty) {
      if (profile.photoUrl.startsWith('data:image')) {
        try {
          final base64Str = profile.photoUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          return CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.bgLight,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      } else if (profile.photoUrl.startsWith('http')) {
        return CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.bgLight,
          backgroundImage: NetworkImage(profile.photoUrl),
        );
      }
    }

    final initial = profile.name.trim().isNotEmpty ? profile.name.trim()[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;

    String displayLocation;
    if (profile.location.isNotEmpty && !profile.location.toLowerCase().contains('village')) {
      displayLocation = profile.location;
    } else if (profile.district.isNotEmpty) {
      displayLocation = '${profile.district}, ${profile.state}';
    } else {
      displayLocation = 'Kolkata, West Bengal';
    }

    final completionPercent = profile.calculateCompletionPercent();
    final journeyPercent = profile.calculateProgressPercent();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Requirement 1 & 8: Welcome Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.tr('scheme_subtitle'),
                                style: const TextStyle(color: AppColors.tealLight, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 2),

                              // Greeting Name + Animated Waving Emoji 👋 on the EXACT same line
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Hello, ${profile.name.isNotEmpty ? profile.name : 'Beneficiary'}',
                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const WavingEmojiWidget(),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Auto-Detected Location Display (No hardcoded Village)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      displayLocation,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      maxLines: 1,
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
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: _buildSmallAvatarWidget(profile),
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
                                Text('Profile Completion – $completionPercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
                                  child: Text(completionPercent == 100 ? 'Complete ✓' : 'Complete Profile →', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completionValueNormalized(completionPercent),
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                color: AppColors.tealLight,
                              ),
                            ),
                            if (profile.missingFields.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Missing: ${profile.missingFields.take(2).join(', ')}${profile.missingFields.length > 2 ? ' +${profile.missingFields.length - 2} more' : ''}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Requirement 1 & 18: Primary AI Voice Assistant Hero Card
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiChatScreen()),
                        );
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
                                  Text(state.tr('start_talking'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  const Text('Tell me about your work & skills', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                                ],
                              ),
                            ),

                            // Interactive Pulsing Voice Waveform Badge
                            const VoiceWaveformPulseWidget(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Contact Icons Row (WhatsApp / Call)
                    const ContactIconsRow(),

                    const SizedBox(height: 20),

                    // 2x2 Grid of Secondary Features (Requirements 3, 4, 5, 7)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: [
                        // Card 1: Livelihood Profile
                        _gridCard(
                          context,
                          title: state.tr('livelihood_profile'),
                          subtitle: profile.livelihood.isNotEmpty ? profile.livelihood : 'Student',
                          icon: Icons.agriculture_rounded,
                          color: AppColors.teal,
                          progress: (completionPercent / 100).clamp(0.1, 1.0),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                          },
                        ),

                        // Card 2: Skill Recommendations (Requirement 3 & 4)
                        _gridCard(
                          context,
                          title: state.tr('skill_recommendations'),
                          subtitle: '4 new matches found',
                          icon: Icons.star_rounded,
                          color: AppColors.orange,
                          actionText: 'View →',
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecommendationsScreen()));
                          },
                        ),

                        // Card 3: Training Near You (Requirement 5)
                        _gridCard(
                          context,
                          title: state.tr('training_near_you'),
                          subtitle: 'PM-AJAY GIA Centers',
                          icon: Icons.school_rounded,
                          color: AppColors.purple,
                          actionText: 'Explore →',
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingScreen()));
                          },
                        ),

                        // Card 4: My Progress (Requirement 7)
                        _gridCard(
                          context,
                          title: state.tr('my_progress'),
                          subtitle: '${state.tr('my_progress')} – $journeyPercent%',
                          icon: Icons.bar_chart_rounded,
                          color: AppColors.navy,
                          progress: journeyPercent / 100.0,
                          progressColor: AppColors.orange,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgressScreen()));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Restored Recent Activity Section (Matching Reference Screenshots)
                    Text(
                      state.tr('recent_activity'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _activityTile(
                            icon: Icons.check_rounded,
                            iconBg: const Color(0xFFDCFCE7),
                            iconFg: const Color(0xFF16A34A),
                            title: completionPercent >= 100 ? 'Profile setup completed' : 'Profile assessment in progress',
                            timeAgo: '2h ago',
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _activityTile(
                            icon: Icons.smart_toy_rounded,
                            iconBg: const Color(0xFFE0F2FE),
                            iconFg: const Color(0xFF0284C7),
                            title: 'AI analyzed your skills',
                            timeAgo: 'Yesterday',
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _activityTile(
                            icon: Icons.school_rounded,
                            iconBg: const Color(0xFFF1F5F9),
                            iconFg: const Color(0xFF64748B),
                            title: '3 training courses matched',
                            timeAgo: '2d ago',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityTile({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String timeAgo,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: iconFg, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
        ),
        Text(
          timeAgo,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  double completionValueNormalized(int percent) {
    final val = percent / 100.0;
    return val < 0.0 ? 0.0 : (val > 1.0 ? 1.0 : val);
  }

  Widget _iconButton(BuildContext context, IconData icon, {bool badge = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? actionText,
    double? progress,
    Color progressColor = AppColors.navy,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            if (actionText != null) ...[
              const SizedBox(height: 6),
              Text(actionText, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade200,
                  color: progressColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
