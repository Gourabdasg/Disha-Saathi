import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ai_chat_screen.dart';
import 'recommendations_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

/// Hosts the 5 primary tabs shown in the bottom navigation bar across the
/// mockups: Home, AI Chat, Skills, Progress, Profile.
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
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border_rounded), label: 'Skills'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
