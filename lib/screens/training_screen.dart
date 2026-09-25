import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isDetectingLocation = false;

  // Requirement 1: Category Filter Options
  static const List<String> _filters = [
    'All',
    'Classroom',
    'Hybrid',
    'Online',
    'Free (GIA Funded)',
    'NSDC Partners',
    'PMKK Centers',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Requirement 2: Detect & Update Location dynamically
  Future<void> _detectLocation() async {
    final state = context.read<AppState>();
    setState(() => _isDetectingLocation = true);
    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final city = data['city'] as String? ?? 'Kolkata';
        final region = data['regionName'] as String? ?? 'West Bengal';
        state.district = city;
        state.stateName = region;
        state.location = '$city, $region';
        state.profile.district = city;
        state.profile.state = region;
        state.profile.location = '$city, $region';
        await state.updateUserProfile(state.profile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Current Location Detected: $city, $region'), backgroundColor: AppColors.teal),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect GPS location. Using saved profile location.'), backgroundColor: AppColors.danger),
        );
      }
    }
    if (mounted) setState(() => _isDetectingLocation = false);
  }

  List<TrainingCourse> _getFilteredCourses() {
    final all = TrainingCourse.mock;
    final query = _searchController.text.trim().toLowerCase();

    var list = all;
    if (query.isNotEmpty) {
      list = list.where((c) => c.title.toLowerCase().contains(query) || c.provider.toLowerCase().contains(query)).toList();
    }

    if (_filter == 'All') return list;
    if (_filter == 'Classroom') return list.where((c) => c.mode.toLowerCase() == 'classroom').toList();
    if (_filter == 'Hybrid') return list.where((c) => c.mode.toLowerCase() == 'hybrid').toList();
    if (_filter == 'Online') return list.where((c) => c.mode.toLowerCase() == 'online').toList();
    if (_filter == 'Free (GIA Funded)') return list.where((c) => c.freeGiaFunded).toList();
    if (_filter == 'NSDC Partners') return list.where((c) => c.provider.toLowerCase().contains('nsdc')).toList();
    if (_filter == 'PMKK Centers') return list.where((c) => c.provider.toLowerCase().contains('pmkk') || c.provider.toLowerCase().contains('kaushal')).toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final locationName = profile.district.isNotEmpty
        ? profile.district
        : (profile.location.isNotEmpty ? profile.location.split(',')[0].trim() : 'Kolkata');

    final courses = _getFilteredCourses();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Filters
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

                      // Requirement 2: Dynamic Location Display Button
                      InkWell(
                        onTap: _isDetectingLocation ? null : _detectLocation,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isDetectingLocation
                                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                                  : const Icon(Icons.location_on, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(locationName, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.search, color: Colors.white60),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Requirement 1: Horizontally Scrollable Category Filter Row
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, idx) {
                        final cat = _filters[idx];
                        final selected = cat == _filter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _filter = cat;
                                _expanded = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.3),
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

            // Courses List
            Expanded(
              child: courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No courses found for "$_filter"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                          const SizedBox(height: 6),
                          const Text('Try selecting "All" to view all training options.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text('${courses.length} courses found near $locationName', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
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
                                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
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
                                            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
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
                                                  SnackBar(
                                                    content: Text('Application enquiry sent for ${c.title}'),
                                                    backgroundColor: AppColors.navy,
                                                  ),
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
