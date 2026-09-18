import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_button.dart';
import 'registration_flow.dart';

class Step4Skills extends StatelessWidget {
  const Step4Skills({super.key});

  static const _skills = [
    ['Computer', Icons.computer_rounded],
    ['Mobile', Icons.smartphone_rounded],
    ['Agriculture', Icons.grass_rounded],
    ['Driving', Icons.directions_car_rounded],
    ['Tailoring', Icons.checkroom_rounded],
    ['Electrical', Icons.bolt_rounded],
    ['Construction', Icons.construction_rounded],
    ['Sales', Icons.sell_rounded],
    ['Cooking', Icons.restaurant_rounded],
    ['Handicrafts', Icons.palette_rounded],
    ['Communication', Icons.record_voice_over_rounded],
  ];

  static const _interests = [
    'Healthcare', 'IT & Technology', 'Retail', 'Manufacturing', 'Agriculture', 'Construction', 'Finance', 'Hospitality',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Which skills do you already have?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _skills.map((s) {
                    final label = s[0] as String;
                    final icon = s[1] as IconData;
                    return SelectableChip(
                      label: label,
                      icon: icon,
                      selected: state.selectedSkills.contains(label),
                      onTap: () => context.read<AppState>().toggleSkill(label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),
                const Text('Career Interests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _interests.map((label) {
                    return SelectableChip(
                      label: label,
                      selected: state.selectedInterests.contains(label),
                      onTap: () => context.read<AppState>().toggleInterest(label),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
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
                  label: state.isLoading ? 'Saving…' : 'Complete Profile',
                  onPressed: state.isLoading ? null : () => RegistrationFlow.finish(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
