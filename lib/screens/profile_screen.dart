import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'our_services_screen.dart';
import 'pm_ajay_details_screen.dart';
import 'privacy_screen.dart';
import 'profile_completion_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            // Top User Info Header
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.buttonGradient),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name.isNotEmpty ? profile.name : 'Beneficiary User', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                        Text(' $displayLocation', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: 4),
                      const Text('SC Category · PM-AJAY Beneficiary', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Stat Chips (Tapping opens Profile Completion / Edit)
            Row(
              children: [
                _statChip(
                  context,
                  state.tr('education'),
                  profile.highestQualification.isNotEmpty ? profile.highestQualification : 'Add Education',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _statChip(
                  context,
                  state.tr('livelihood'),
                  profile.livelihood.isNotEmpty ? profile.livelihood : 'Add Work',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _statChip(context, 'NSQF', state.tr('nsqf_level'), () {}),
              ],
            ),
            const SizedBox(height: 20),

            // My Skills Section
            _sectionCard(
              title: state.tr('my_skills'),
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                );
              },
              child: profile.existingSkills.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.existingSkills.map((s) => _pill(s, AppColors.navy)).toList(),
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 16, color: AppColors.navy),
                            const SizedBox(width: 4),
                            Text(state.tr('add_skills'), style: const TextStyle(color: AppColors.navy, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Career Interests Section
            _sectionCard(
              title: state.tr('career_interests'),
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                );
              },
              child: profile.careerInterests.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.careerInterests.map((s) => _pill(s, AppColors.teal)).toList(),
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 16, color: AppColors.teal),
                            const SizedBox(width: 4),
                            Text(state.tr('add_career_interests'), style: const TextStyle(color: AppColors.teal, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            Text(state.tr('account_section'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _listCard([
              _tile(Icons.edit_note_rounded, state.tr('edit_profile'), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()));
              }),
              const Divider(height: 1),
              _tile(Icons.settings_rounded, state.tr('settings'), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
            ]),
            const SizedBox(height: 20),

            Text(state.tr('scheme_section'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _listCard([
              _tile(Icons.description_rounded, state.tr('pm_ajay_details'), () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PmAjayGiaDetailsScreen()),
                );
              }),
            ]),
            const SizedBox(height: 20),

            Text(state.tr('about_legal'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _listCard([
              _tile(Icons.design_services_rounded, state.tr('our_services'), () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OurServicesScreen()),
                );
              }),
              const Divider(height: 1),
              _tile(Icons.gavel_rounded, state.tr('terms_conditions'), () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
                );
              }),
              const Divider(height: 1),
              _tile(Icons.privacy_tip_rounded, state.tr('privacy_policy'), () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              }),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AppState>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(state.tr('logout'), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, required VoidCallback onEdit}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              TextButton(onPressed: onEdit, child: const Text('Edit', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _listCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: tiles),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
