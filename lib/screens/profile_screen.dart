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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildAvatarWidget(UserProfile profile) {
    if (profile.photoUrl.isNotEmpty) {
      if (profile.photoUrl.startsWith('data:image')) {
        try {
          final base64Str = profile.photoUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          return CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.bgLight,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      } else if (profile.photoUrl.startsWith('http')) {
        return CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.bgLight,
          backgroundImage: NetworkImage(profile.photoUrl),
        );
      }
    }

    final initial = profile.name.trim().isNotEmpty ? profile.name.trim()[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 32,
      backgroundColor: AppColors.navy,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
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
          padding: const EdgeInsets.all(20),
          children: [
            // Top User Info Header (Tapping opens Edit Profile Screen)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildAvatarWidget(profile),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(profile.name.isNotEmpty ? profile.name : 'Beneficiary User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ),
                              const Icon(Icons.edit_rounded, size: 18, color: AppColors.navy),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                            Text(' $displayLocation', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                          ]),
                          if (profile.bio.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontStyle: FontStyle.italic),
                            ),
                          ],
                          const SizedBox(height: 4),
                          const Text('SC Category · PM-AJAY Beneficiary', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Top Stat Chips (Tapping opens Profile Completion / Edit)
            Row(
              children: [
                Expanded(
                  child: _statCard('Education', profile.highestQualification.isNotEmpty ? profile.highestQualification : 'Add Education', onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard('Livelihood', profile.livelihood.isNotEmpty ? profile.livelihood : 'Add Livelihood', onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard('NSQF', 'NSQF Level 3', onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Skills Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.tr('my_skills'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  },
                  child: Text(state.tr('add_skills'), style: const TextStyle(color: AppColors.navy, fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.existingSkills.isNotEmpty
                  ? profile.existingSkills.map((s) => _chip(s)).toList()
                  : [
                      ActionChip(
                        label: Text(state.tr('add_skills'), style: const TextStyle(fontSize: 12, color: AppColors.navy)),
                        backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                          );
                        },
                      ),
                    ],
            ),
            const SizedBox(height: 24),

            // Career Interests Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.tr('career_interests'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  },
                  child: Text(state.tr('add_skills'), style: const TextStyle(color: AppColors.navy, fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.careerInterests.isNotEmpty
                  ? profile.careerInterests.map((i) => _chip(i)).toList()
                  : [
                      ActionChip(
                        label: Text(state.tr('add_career_interests'), style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                        backgroundColor: AppColors.teal.withValues(alpha: 0.08),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                          );
                        },
                      ),
                    ],
            ),
            const SizedBox(height: 24),

            // Settings & Legal List
            Text(state.tr('account_section'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _menuTile(Icons.assignment_ind_outlined, state.tr('edit_profile'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
              );
            }),
            _menuTile(Icons.settings_outlined, state.tr('settings'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),

            const SizedBox(height: 20),
            Text(state.tr('scheme_section'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _menuTile(Icons.account_balance_outlined, state.tr('pm_ajay_details'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PmAjayDetailsScreen()),
              );
            }),

            const SizedBox(height: 20),
            Text(state.tr('about_legal'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _menuTile(Icons.business_center_outlined, state.tr('our_services'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OurServicesScreen()),
              );
            }),
            _menuTile(Icons.description_outlined, state.tr('terms_conditions'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            }),
            _menuTile(Icons.privacy_tip_outlined, state.tr('privacy_policy'), onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            }),

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
    );
  }

  Widget _statCard(String label, String value, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
      child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
    );
  }

  Widget _menuTile(IconData icon, String title, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.navy, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
