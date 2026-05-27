import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'admin_approvals.dart';
import 'admin_broadcast.dart';
import 'admin_overview.dart';
import 'admin_tournaments.dart';
import 'admin_users.dart';
import 'core_shared.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  final _tabs = const [
    _NavItem(Icons.dashboard_customize_rounded, 'Overview'),
    _NavItem(Icons.emoji_events_rounded, 'Tournaments'),
    _NavItem(Icons.how_to_reg_rounded, 'Approvals'),
    _NavItem(Icons.groups_rounded, 'Users'),
    _NavItem(Icons.campaign_rounded, 'Broadcast'),
  ];

  @override
  void initState() {
    super.initState();
    DB.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _signOut() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Sign out of admin console?',
      message:
          'This will clear the current admin session and return you to the login screen.',
      confirmLabel: 'Sign Out',
      confirmColor: AC.red,
      icon: Icons.logout_rounded,
    );

    if (!confirm || !mounted) return;

    await AuthService().clearUserSession();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg1,
      appBar: AppBar(
        backgroundColor: AC.bg0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AC.gradPrimaryVert,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AC.cyan.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: AC.bg0,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GameArena',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AC.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Admin Operations',
                  style: AT.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _signOut,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AC.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AC.red.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded, color: AC.red, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Sign Out',
                      style: AT.caption.copyWith(
                        color: AC.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AC.border),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          AdminOverviewView(
              onNavigate: (index) => setState(() => _tab = index)),
          const AdminTournamentsView(),
          const AdminApprovalsView(),
          const AdminUsersView(),
          const AdminBroadcastView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AC.bg0,
          border: Border(top: BorderSide(color: AC.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = _tab == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tab = index);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AC.cyan.withOpacity(0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? AC.cyan.withOpacity(0.25)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: isActive ? AC.cyan : AC.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AC.cyan : AC.textMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}
