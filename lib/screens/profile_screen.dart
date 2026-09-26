import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'our_services_screen.dart';
import 'pm_ajay_details_screen.dart';
import 'privacy_screen.dart';
import 'profile_completion_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeHeader;
  late final Animation<Offset> _slideHeader;
  late final Animation<double> _scaleStats;
  late final Animation<double> _fadeContent;
  late final Animation<Offset> _slideContent;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeHeader = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideHeader = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    ));

    _scaleStats = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    );

    _fadeContent = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _slideContent = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildAvatarWidget(UserProfile profile) {
    if (profile.photoUrl.isNotEmpty) {
      if (profile.photoUrl.startsWith('data:image')) {
        try {
          final base64Str = profile.photoUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          return CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.bgLight,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      } else if (profile.photoUrl.startsWith('http')) {
        return CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.bgLight,
          backgroundImage: NetworkImage(profile.photoUrl),
        );
      }
    }

    final initial = profile.name.trim().isNotEmpty ? profile.name.trim()[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.navy,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final displayLocation = profile.location.isNotEmpty
        ? profile.location
        : (profile.district.isNotEmpty ? '${profile.district}, ${profile.state}' : 'Barasat, West Bengal');

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            // 1. Profile Header Section (Fade + Slide Entrance)
            FadeTransition(
              opacity: _fadeHeader,
              child: SlideTransition(
                position: _slideHeader,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _buildAvatarWidget(profile),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.teal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile.name.isNotEmpty ? profile.name : 'Beneficiary User',
                                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.teal),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      displayLocation,
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (profile.bio.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  profile.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontStyle: FontStyle.italic),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'SC Category · PM-AJAY Beneficiary',
                                  style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 2. Stat Cards Section (Scale Entrance)
            ScaleTransition(
              scale: _scaleStats,
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Education',
                      profile.highestQualification.isNotEmpty ? profile.highestQualification : 'Add Education',
                      Icons.school_outlined,
                      AppColors.navy,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Livelihood',
                      profile.livelihood.isNotEmpty ? profile.livelihood : 'Add Livelihood',
                      Icons.work_outline_rounded,
                      AppColors.teal,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'NSQF',
                      'NSQF Level 3',
                      Icons.verified_outlined,
                      AppColors.orange,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 3. Main Content Sections (Fade + Slide Entrance)
            FadeTransition(
              opacity: _fadeContent,
              child: SlideTransition(
                position: _slideContent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skills Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology_rounded, size: 20, color: AppColors.navy),
                                  const SizedBox(width: 8),
                                  Text(state.tr('my_skills'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                                },
                                child: Text(state.tr('add_skills'), style: const TextStyle(color: AppColors.navy, fontSize: 12.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.existingSkills.isNotEmpty
                                ? profile.existingSkills.map((s) => _chip(s, AppColors.navy)).toList()
                                : [
                                    ActionChip(
                                      label: Text(state.tr('add_skills'), style: const TextStyle(fontSize: 12, color: AppColors.navy)),
                                      backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                                      },
                                    ),
                                  ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Career Interests Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.teal),
                                  const SizedBox(width: 8),
                                  Text(state.tr('career_interests'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                                },
                                child: Text(state.tr('add_skills'), style: const TextStyle(color: AppColors.teal, fontSize: 12.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.careerInterests.isNotEmpty
                                ? profile.careerInterests.map((i) => _chip(i, AppColors.teal)).toList()
                                : [
                                    ActionChip(
                                      label: Text(state.tr('add_career_interests'), style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                                      backgroundColor: AppColors.teal.withValues(alpha: 0.08),
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                                      },
                                    ),
                                  ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Account Menu Group
                    Text(state.tr('account_section'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          _menuTile(Icons.assignment_ind_outlined, state.tr('edit_profile'), onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
                          }),
                          const Divider(height: 1, indent: 50),
                          _menuTile(Icons.settings_outlined, state.tr('settings'), onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Scheme Menu Group
                    Text(state.tr('scheme_section'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                      ),
                      child: _menuTile(Icons.account_balance_outlined, state.tr('pm_ajay_details'), onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PmAjayGiaDetailsScreen()));
                      }),
                    ),

                    const SizedBox(height: 18),

                    // About & Legal Menu Group
                    Text(state.tr('about_legal'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          _menuTile(Icons.business_center_outlined, state.tr('our_services'), onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OurServicesScreen()));
                          }),
                          const Divider(height: 1, indent: 50),
                          _menuTile(Icons.description_outlined, state.tr('terms_conditions'), onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                          }),
                          const Divider(height: 1, indent: 50),
                          _menuTile(Icons.privacy_tip_outlined, state.tr('privacy_policy'), onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(state.tr('logout')),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  state.logout();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                      label: Text(state.tr('logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _menuTile(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
