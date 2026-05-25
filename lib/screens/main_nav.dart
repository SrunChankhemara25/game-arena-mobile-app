import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'explore/explore_screen.dart';
import 'tournament/tournaments_screen.dart';
import 'team/my_team_screen.dart';
import 'profile/profile_screen.dart';

// ─── Premium Glass-Morphic Navigation Core ───────────────────────────────────
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
    
    // Tactile click haptic on tab engagement
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
      backgroundColor: AppColors.bg0,
      extendBody: true, // Crucial for showing content behind the frosted glass bar
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

// ─── Frosted Glass Floating Navigation Bar ───────────────────────────────────
class _ObsidianBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ObsidianBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.bg1.withOpacity(0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ObsidianNavItem(
                  icon: Icons.explore_rounded,
                  label: 'EXPLORE',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _ObsidianNavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'TOURNAMENTS',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _ObsidianNavItem(
                  icon: Icons.groups_rounded,
                  label: 'SQUAD HUB',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _ObsidianNavItem(
                  icon: Icons.person_rounded,
                  label: 'PROFILE',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Interactive Tab Item ───────────────────────────────────────────
class _ObsidianNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ObsidianNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.cyan;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Micro-Interactions: Scaling & shifting background container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? activeColor.withOpacity(0.25) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: isActive ? 1.12 : 1.0,
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 5),
            
            // Dynamic Typography Transitions
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppText.caption.copyWith(
                color: isActive ? activeColor : AppColors.textMuted,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: isActive ? 0.8 : 0.4,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}