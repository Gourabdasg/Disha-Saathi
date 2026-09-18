import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class Step2Education extends StatefulWidget {
  const Step2Education({super.key});

  @override
  State<Step2Education> createState() => _Step2EducationState();
}

class _Step2EducationState extends State<Step2Education> {
  String? _qualification;
  String? _stream;
  final _years = TextEditingController();
  final _experience = TextEditingController();

  static const _qualifications = ['Below 8th', '8th Pass', '10th Pass', '12th Pass', 'ITI / Diploma', "Graduate", "Post Graduate"];
  static const _streams = ['General', 'Science', 'Commerce', 'Arts', 'Vocational', 'Not Applicable'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('HIGHEST QUALIFICATION'),
          _dropdown(_qualification, 'Select Highest Qualification', _qualifications, (v) => setState(() => _qualification = v)),
          const SizedBox(height: 16),
          _label('STREAM / SUBJECT'),
          _dropdown(_stream, 'Select Stream / Subject', _streams, (v) => setState(() => _stream = v)),
          const SizedBox(height: 16),
          _label('YEARS OF STUDY COMPLETED'),
          TextField(controller: _years, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'E.g. 10')),
          const SizedBox(height: 16),
          _label('WORK EXPERIENCE (YEARS)'),
          TextField(controller: _experience, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0 if no experience')),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.read<AppState>().prevRegistrationStep(),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Back', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: 'Continue',
                  onPressed: () {
                    final state = context.read<AppState>();
                    state.highestQualification = _qualification ?? '';
                    state.stream = _stream ?? '';
                    state.yearsOfStudy = _years.text;
                    state.workExperience = _experience.text;
                    state.nextRegistrationStep();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted)),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
      );
}
