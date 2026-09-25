import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'training_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  final bool embedded; // true when hosted inside bottom-nav shell
  const RecommendationsScreen({super.key, this.embedded = false});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  int? _expanded = 0;
  String _filter = 'All';

  static const List<String> _categories = [
    'All',
    'Digital',
    'Technical',
    'Healthcare',
    'Agriculture',
    'Retail',
    'NSQF L2',
    'NSQF L3',
    'Saved',
  ];

  List<SkillRecommendation> _getFilteredItems() {
    final all = SkillRecommendation.mock;
    if (_filter == 'All') return all;
    if (_filter == 'Digital') {
      return all.where((item) => item.title.toLowerCase().contains('digital') || item.title.toLowerCase().contains('data')).toList();
    }
    if (_filter == 'Technical') {
      return all.where((item) => item.colorKey == 'purple' || item.nsqfLevel >= 3).toList();
    }
    if (_filter == 'Healthcare') {
      return all.where((item) => item.title.toLowerCase().contains('customer') || item.colorKey == 'orange').toList();
    }
    if (_filter == 'Agriculture') {
      return all.where((item) => item.colorKey == 'teal' || item.title.toLowerCase().contains('retail')).toList();
    }
    if (_filter == 'Retail') {
      return all.where((item) => item.title.toLowerCase().contains('retail')).toList();
    }
    if (_filter == 'NSQF L2') {
      return all.where((item) => item.nsqfLevel == 2).toList();
    }
    if (_filter == 'NSQF L3') {
      return all.where((item) => item.nsqfLevel == 3).toList();
    }
    if (_filter == 'Saved') {
      return all.take(2).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = _getFilteredItems();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header & Category Filter Row
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.embedded)
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  const Text(
                    'AI RECOMMENDATIONS',
                    style: TextStyle(color: AppColors.tealLight, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Text(state.tr('rec_header'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(state.tr('rec_subtitle'), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  const SizedBox(height: 16),

                  // Category Filter Row
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final selected = cat == _filter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _filter = cat;
                                _expanded = 0;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  if (selected) const Icon(Icons.check, size: 14, color: AppColors.navy),
                                  if (selected) const SizedBox(width: 4),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? AppColors.navy : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Filtered Items List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('No recommendations found for "$_filter"', style: const TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isExpanded = _expanded == i;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded ? AppColors.navy : const Color(0xFFE5E7EB),
                              width: isExpanded ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _iconBg(item.colorKey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_iconFor(item.colorKey), color: _iconColor(item.colorKey), size: 22),
                                ),
                                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Row(
                                  children: [
                                    PillTag('${item.matchPercent}% Match', bg: AppColors.navy, fg: Colors.white),
                                    const SizedBox(width: 6),
                                    PillTag('Level ${item.nsqfLevel}', bg: AppColors.bgLight, fg: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(item.duration, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                                trailing: Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: AppColors.textMuted,
                                ),
                                onTap: () => setState(() => _expanded = isExpanded ? null : i),
                              ),

                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Text(state.tr('skills_to_learn'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: item.skills.map((s) => _skillChip(s)).toList(),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('💰 ${state.tr('expected_salary')}', style: const TextStyle(fontSize: 12.5, color: AppColors.textDark)),
                                            Text(item.expectedSalary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const TrainingScreen()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.navy,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: Text(state.tr('find_training'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
    );
  }

  Color _iconBg(String key) {
    switch (key) {
      case 'purple':
        return AppColors.purple.withOpacity(0.12);
      case 'orange':
        return AppColors.orange.withOpacity(0.12);
      case 'teal':
        return AppColors.teal.withOpacity(0.12);
      default:
        return AppColors.navy.withOpacity(0.12);
    }
  }

  Color _iconColor(String key) {
    switch (key) {
      case 'purple':
        return AppColors.purple;
      case 'orange':
        return AppColors.orange;
      case 'teal':
        return AppColors.teal;
      default:
        return AppColors.navy;
    }
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'purple':
        return Icons.computer_rounded;
      case 'orange':
        return Icons.people_outline_rounded;
      case 'teal':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.data_usage_rounded;
    }
  }
}
