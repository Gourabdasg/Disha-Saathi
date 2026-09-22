import 'package:flutter/material.dart';
import '../models/app_models.dart';
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

  // Requirement 1 & 3: Dynamic Category Options
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
                  const Text('Recommended Skills For You', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Based on your profile · NSQF-aligned pathways', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                  const SizedBox(height: 16),

                  // Requirement 2: Horizontally Scrollable Category Filter Row
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
                                _expanded = 0; // Expand first item in filtered list
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (selected) ...[
                                    const Icon(Icons.check_rounded, size: 15, color: AppColors.navy),
                                    const SizedBox(width: 5),
                                  ],
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      color: selected ? AppColors.navy : Colors.white,
                                      fontSize: 13,
                                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No courses match "$_filter"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                          const SizedBox(height: 6),
                          const Text('Try selecting "All" to view all recommendations.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final rec = items[i];
                        final expanded = _expanded == i;
                        final color = colorFor(rec.colorKey);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _expanded = expanded ? null : i),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(iconFor(rec.icon), color: color),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(rec.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                TagBadge(label: '${rec.matchPercent}% Match', color: color),
                                                const SizedBox(width: 8),
                                                TagBadge(label: 'Level ${rec.nsqfLevel}', color: Colors.grey.shade200, textColor: AppColors.textDark),
                                                const SizedBox(width: 8),
                                                Text(rec.duration, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                              if (expanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('💡 ', style: TextStyle(fontSize: 14)),
                                          Expanded(
                                            child: Text(rec.insight, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text('SKILL GAP PATHWAY', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.4)),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: List.generate(rec.pathway.length * 2 - 1, (idx) {
                                          if (idx.isOdd) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 4),
                                              child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                                            );
                                          }
                                          final stepIdx = idx ~/ 2;
                                          final isLast = stepIdx == rec.pathway.length - 1;
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isLast ? color : color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(rec.pathway[stepIdx],
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isLast ? Colors.white : color)),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('SKILLS TO LEARN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.4)),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: rec.skillsToLearn
                                            .map((s) => Chip(
                                                  label: Text(s, style: const TextStyle(fontSize: 12)),
                                                  backgroundColor: AppColors.bgLight,
                                                  side: BorderSide.none,
                                                ))
                                            .toList(),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Row(
                                          children: [
                                            const Text('💰 ', style: TextStyle(fontSize: 14)),
                                            const Text('Expected Salary', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                                            const Spacer(),
                                            Text(rec.expectedSalary, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingScreen()));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: color,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 13),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Find Training', style: TextStyle(fontWeight: FontWeight.w600)),
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
}
