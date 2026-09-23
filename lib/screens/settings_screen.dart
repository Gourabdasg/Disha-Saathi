import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _sms = true;
  bool _voiceAssistant = true;
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ]),
                  Text(state.tr('settings'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text('Customize your experience', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionLabel('LANGUAGE & REGION'),
                  _card([
                    _navTile(
                      'App Language',
                      '${state.selectedLanguage.englishName} (${state.selectedLanguage.nativeName})',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('NOTIFICATIONS'),
                  _card([
                    _switchTile('Push Notifications', 'Recommendations & training alerts', _push, (v) => setState(() => _push = v)),
                    const Divider(height: 1),
                    _switchTile('SMS Alerts', 'Important scheme updates', _sms, (v) => setState(() => _sms = v)),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('ACCESSIBILITY'),
                  _card([
                    _switchTile('Voice Assistant', 'Enable AI voice interaction', _voiceAssistant, (v) => setState(() => _voiceAssistant = v)),
                    const Divider(height: 1),
                    _switchTile('Large Text', 'Increase font size for readability', _largeText, (v) => setState(() => _largeText = v)),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('PRIVACY & ABOUT'),
                  _card([
                    _navTile('Privacy Policy', 'How we handle your data', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                    }),
                    const Divider(height: 1),
                    _navTile('Terms of Service', 'PM-AJAY GIA terms', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                    }),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
      );

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _navTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Change', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 13)),
          Icon(Icons.chevron_right, color: AppColors.navy),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      value: value,
      activeColor: AppColors.teal,
      onChanged: onChanged,
    );
  }
}
