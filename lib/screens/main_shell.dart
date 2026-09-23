import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'ai_chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'recommendations_screen.dart';

/// Hosts the 5 primary tabs shown in the bottom navigation bar across the
/// mockups: Home, AI Chat, Skills, Progress, Profile with global localized labels.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    AiChatScreen(),
    RecommendationsScreen(embedded: true),
    ProgressScreen(embedded: true),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: state.tr('nav_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline_rounded), label: state.tr('nav_chat')),
          BottomNavigationBarItem(icon: const Icon(Icons.star_border_rounded), label: state.tr('nav_skills')),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_rounded), label: state.tr('nav_progress')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), label: state.tr('nav_profile')),
        ],
      ),
    );
  }
}
