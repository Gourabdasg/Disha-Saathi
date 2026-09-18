import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String _filter = 'All';
  int? _expanded;
  final _filters = ['All', 'Free', 'Near Me', '< 3 Months', 'Classroom', 'Online'];

  @override
  Widget build(BuildContext context) {
    final courses = TrainingCourse.mock;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NEARBY TRAINING', style: TextStyle(color: AppColors.tealLight, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                            SizedBox(height: 4),
                            Text('Training Opportunities', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Murshidabad', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.search, color: Colors.white60),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final f = _filters[i];
                        final selected = f == _filter;
                        return ChoiceChip(
                          label: Text(f, style: TextStyle(color: selected ? AppColors.navy : Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          selected: selected,
                          onSelected: (_) => setState(() => _filter = f),
                          backgroundColor: Colors.white.withOpacity(0.15),
                          selectedColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('${courses.length} courses found near you', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 12),
                  ...List.generate(courses.length, (i) {
                    final c = courses[i];
                    final expanded = _expanded == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _expanded = expanded ? null : i),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                      child: Icon(iconFor(c.icon), color: AppColors.navy),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                          Text(c.provider, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 10,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Row(mainAxisSize: MainAxisSize.min, children: [
                                                const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                                                Text(' ${c.distanceKm} km', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                              ]),
                                              Row(mainAxisSize: MainAxisSize.min, children: [
                                                const Icon(Icons.access_time_filled, size: 13, color: AppColors.textMuted),
                                                Text(' ${c.duration}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                              ]),
                                              Text('Level ${c.nsqfLevel}', style: const TextStyle(fontSize: 12, color: AppColors.purple, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              if (c.freeGiaFunded) const TagBadge(label: 'Free (GIA Funded)', color: AppColors.success),
                                              if (c.seatsLeft != null) TagBadge(label: 'Only ${c.seatsLeft} seats!', color: AppColors.warning),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (expanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    const Divider(),
                                    Row(
                                      children: [
                                        Expanded(child: _detail('Mode', c.mode)),
                                        Expanded(child: _detail('Schedule', c.schedule)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(child: _detail('Eligibility', c.eligibility)),
                                        Expanded(child: _detail('Seats Left', '${c.seatsLeft ?? '—'} seats')),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Application enquiry sent for ${c.title}')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.navy,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 13),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
