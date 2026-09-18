import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class Step3Livelihood extends StatefulWidget {
  const Step3Livelihood({super.key});

  @override
  State<Step3Livelihood> createState() => _Step3LivelihoodState();
}

class _LivelihoodOption {
  final String label;
  final IconData icon;
  const _LivelihoodOption(this.label, this.icon);
}

class _Step3LivelihoodState extends State<Step3Livelihood> {
  String? _selected;

  static const _options = [
    _LivelihoodOption('Agriculture', Icons.grass_rounded),
    _LivelihoodOption('Daily Wage', Icons.construction_rounded),
    _LivelihoodOption('Self-employed', Icons.storefront_rounded),
    _LivelihoodOption('Small Business', Icons.store_rounded),
    _LivelihoodOption('Private Job', Icons.work_outline_rounded),
    _LivelihoodOption('Government Job', Icons.account_balance_rounded),
    _LivelihoodOption('Skilled Trade', Icons.settings_rounded),
    _LivelihoodOption('Student', Icons.menu_book_rounded),
    _LivelihoodOption('Unemployed', Icons.search_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('What best describes your current livelihood?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: _options.map((opt) {
                    final selected = _selected == opt.label;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selected = opt.label),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? AppColors.navy : Colors.transparent, width: 1.6),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(opt.icon, size: 28, color: selected ? AppColors.navy : AppColors.teal),
                            const SizedBox(height: 8),
                            Text(opt.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.navy : AppColors.textDark)),
                          ],
                        ),
                      ),
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
                  label: 'Continue',
                  onPressed: _selected == null
                      ? null
                      : () {
                          context.read<AppState>().selectedLivelihood = _selected!;
                          context.read<AppState>().nextRegistrationStep();
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
