import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  late final TextEditingController _qualification;
  late final TextEditingController _stream;
  late final TextEditingController _yearOfQual;
  late final TextEditingController _expName;
  late final TextEditingController _expDuration;
  late final TextEditingController _livelihood;
  late final TextEditingController _skills;
  late final TextEditingController _interests;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    _qualification = TextEditingController(text: profile.highestQualification);
    _stream = TextEditingController(text: profile.stream);
    _yearOfQual = TextEditingController(text: profile.yearOfQualification);
    _expName = TextEditingController(text: profile.experienceName);
    _expDuration = TextEditingController(text: profile.experienceDuration);
    _livelihood = TextEditingController(text: profile.livelihood);
    _skills = TextEditingController(text: profile.existingSkills.join(', '));
    _interests = TextEditingController(text: profile.careerInterests.join(', '));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.teal),
    );
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    final profile = state.profile;

    profile.highestQualification = _qualification.text.trim();
    profile.stream = _stream.text.trim();
    profile.yearOfQualification = _yearOfQual.text.trim();
    profile.experienceName = _expName.text.trim();
    profile.experienceDuration = _expDuration.text.trim();
    profile.livelihood = _livelihood.text.trim();

    final skillsList = _skills.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final interestsList = _interests.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    profile.existingSkills
      ..clear()
      ..addAll(skillsList);

    profile.careerInterests
      ..clear()
      ..addAll(interestsList);

    final ok = await state.updateUserProfile(profile);
    if (!mounted) return;
    if (ok) {
      _showSuccess('Profile updated successfully! Completion: ${profile.calculateCompletionPercent()}%');
      Navigator.pop(context);
    } else {
      _showSuccess('Saved locally. Profile Completion: ${profile.calculateCompletionPercent()}%');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final completion = state.profile.calculateCompletionPercent();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  const Text('Complete Your Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Profile Completion: $completion%', style: const TextStyle(color: AppColors.tealLight, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completion / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      color: AppColors.tealLight,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionTitle('EDUCATION INFORMATION'),
                  _label('Highest Qualification'),
                  TextField(
                    controller: _qualification,
                    decoration: const InputDecoration(hintText: 'e.g. 10th Pass, 12th Pass, Graduate, B.Tech'),
                  ),
                  const SizedBox(height: 14),
                  _label('Stream / Major'),
                  TextField(
                    controller: _stream,
                    decoration: const InputDecoration(hintText: 'e.g. Arts, Science, Commerce, Computer Science'),
                  ),
                  const SizedBox(height: 14),
                  _label('Year of Highest Qualification'),
                  TextField(
                    controller: _yearOfQual,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 2022, 2023'),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('WORK EXPERIENCE'),
                  _label('Work / Job / Experience Name'),
                  TextField(
                    controller: _expName,
                    decoration: const InputDecoration(hintText: 'e.g. Data Entry Intern, Tailoring, Electrical Repair'),
                  ),
                  const SizedBox(height: 14),
                  _label('Experience Duration'),
                  TextField(
                    controller: _expDuration,
                    decoration: const InputDecoration(hintText: 'e.g. 6 months, 1 year, 2 years'),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('LIVELIHOOD & SKILLS'),
                  _label('Current Livelihood / Occupation'),
                  TextField(
                    controller: _livelihood,
                    decoration: const InputDecoration(hintText: 'e.g. Agriculture, Daily Wage, Self-Employed'),
                  ),
                  const SizedBox(height: 14),
                  _label('Skills (separated by comma)'),
                  TextField(
                    controller: _skills,
                    decoration: const InputDecoration(hintText: 'e.g. Computer Operation, Tailoring, Typing, Repair'),
                  ),
                  const SizedBox(height: 14),
                  _label('Career Interests (separated by comma)'),
                  TextField(
                    controller: _interests,
                    decoration: const InputDecoration(hintText: 'e.g. Digital Office, IT Jobs, Retail, Government Jobs'),
                  ),
                  const SizedBox(height: 30),

                  GradientButton(
                    label: state.isLoading ? 'Saving Profile…' : 'Save & Update Profile',
                    onPressed: state.isLoading ? null : _save,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.6)),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
      );
}
