import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class Step1PersonalInfo extends StatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  late final TextEditingController _mobile;
  late final TextEditingController _name;
  final _income = TextEditingController();
  String _category = 'Scheduled Caste (SC)';

  static const _categories = ['Scheduled Caste (SC)', 'Scheduled Tribe (ST)', 'OBC', 'General'];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _mobile = TextEditingController(text: appState.mobile);
    _name = TextEditingController(text: appState.name);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('YOUR NAME'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Full name'),
          ),
          const SizedBox(height: 18),
          _label('MOBILE NUMBER'),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(hintText: '10-digit mobile number', counterText: ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _label('ANNUAL INCOME'),
          TextField(
            controller: _income,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Family annual income'),
          ),
          const SizedBox(height: 18),
          _label('CATEGORY'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ),
          const SizedBox(height: 36),
          GradientButton(
            label: 'Continue',
            onPressed: () {
              final name = _name.text.trim();
              final mobile = _mobile.text.trim();
              if (name.isEmpty) {
                _showError('Enter your name');
                return;
              }
              if (mobile.length != 10) {
                _showError('Enter a valid 10-digit mobile number');
                return;
              }
              final state = context.read<AppState>();
              state.name = name;
              state.mobile = mobile;
              state.annualIncome = _income.text;
              state.category = _category;
              state.nextRegistrationStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
  );
}
