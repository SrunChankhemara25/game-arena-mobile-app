// lib/screens/main_nav.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'explore/explore_screen.dart';
import 'tournament/tournaments_screen.dart';
import 'team/my_team_screen.dart';
import 'profile/profile_screen.dart';

class MainNav extends StatefulWidget {
  final bool isAdmin;
  const MainNav({super.key, this.isAdmin = false});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
        const ExploreScreen(),
        const TournamentsScreen(),
        const MyTeamScreen(),
        ProfileScreen(isAdmin: widget.isAdmin),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _ObsidianBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

class _ObsidianBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ObsidianBottomNavBar(
      {required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF101423).withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2B3046).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, Icons.explore_outlined, 'Explore'),
              _buildTabItem(1, Icons.emoji_events_outlined, 'Tournaments'),
              _buildTabItem(2, Icons.group_outlined, 'My Team'),
              _buildTabItem(3, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    final activeColor = const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        width: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? activeColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? activeColor : const Color(0xFF6B738C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : const Color(0xFF6B738C),
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
