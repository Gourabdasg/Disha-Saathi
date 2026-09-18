import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppState>().profile;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                  child: Text(profile.name.isNotEmpty ? profile.name[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                        Text(' ${profile.district}, ${profile.state}', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: 4),
                      const Text('SC Category · PM-AJAY Beneficiary', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _statChip('Education', profile.highestQualification),
                const SizedBox(width: 10),
                _statChip('Livelihood', profile.livelihood),
                const SizedBox(width: 10),
                _statChip('NSQF', 'Level 3'),
              ],
            ),
            const SizedBox(height: 20),
            _sectionCard(
              title: 'My Skills',
              onEdit: () {},
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.existingSkills.map((s) => _pill(s, AppColors.navy)).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Career Interests',
              onEdit: () {},
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.careerInterests.map((s) => _pill(s, AppColors.teal)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _listCard([
              _tile(Icons.settings_rounded, 'Settings', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
            ]),
            const SizedBox(height: 20),
            const Text('SCHEME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _listCard([
              _tile(Icons.description_rounded, 'PM-AJAY GIA Details', () {}),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Logout · लॉग आउट करें', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
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
