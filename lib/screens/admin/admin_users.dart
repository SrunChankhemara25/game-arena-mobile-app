import 'dart:async';

import 'package:flutter/material.dart';

import 'core_shared.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  String _search = '';
  bool _loading = true;
  StreamSubscription<List<AppUser>>? _usersSub;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    await DB.initialize();
    if (!mounted) return;
    setState(() => _loading = false);
    // Subscribe to live user updates after initial load
    _usersSub = DB.watchUsers().listen((users) {
      if (!mounted) return;
      DB.users = users;
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await DB.refresh();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = DB.users.where((user) {
      final query = _search.trim().toLowerCase();
      if (query.isEmpty) return true;
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          (user.country?.toLowerCase().contains(query) ?? false);
    }).toList();

    final activeCount =
        DB.users.where((u) => u.status == UserStatus.active).length;
    final suspendedCount =
        DB.users.where((u) => u.status == UserStatus.suspended).length;

    return Column(
      children: [
        // ── Fixed header ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: cardDecor(
                  radius: 22,
                  border: AC.pink.withOpacity(0.16),
                  gradient: AC.gradHero,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AC.gradPrimaryVert,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.groups_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All registered accounts. Tap ••• to delete a user.',
                        style: AT.body.copyWith(fontSize: 13),
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: _refresh,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AC.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AC.cyan.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: AC.cyan, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                style: const TextStyle(color: AC.textPrimary),
                onChanged: (value) => setState(() => _search = value),
                decoration: fieldDecor(
                  hint: 'Search by name, email, or role',
                  icon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 12),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total',
                      value: '${DB.users.length}',
                      tone: AC.cyan,
                      icon: Icons.people_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Active',
                      value: '$activeCount',
                      tone: AC.green,
                      icon: Icons.verified_user_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Suspended',
                      value: '$suspendedCount',
                      tone: AC.red,
                      icon: Icons.block_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Scrollable user list ─────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AC.cyan),
                )
              : users.isEmpty
                  ? const EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No users found',
                      subtitle:
                          'Try a different keyword or clear the current search.',
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AC.cyan,
                      backgroundColor: AC.bg2,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        itemCount: users.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final tone = userStatusColor(user.status);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration:
                                cardDecor(border: tone.withOpacity(0.18)),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: tone.withOpacity(0.12),
                                  child: Text(
                                    compactInitials(user.name, maxChars: 1),
                                    style: TextStyle(
                                      color: tone,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user.name, style: AT.subheading),
                                      const SizedBox(height: 3),
                                      Text(
                                        user.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AT.caption,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _RoleBadge(role: user.role),
                                          if (user.country != null) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '• ${user.country}',
                                              style: AT.caption.copyWith(
                                                  color: AC.textSecondary),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Status + menu
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusBadge(
                                      label: user.status.label,
                                      color: tone,
                                    ),
                                    const SizedBox(height: 8),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_horiz_rounded,
                                          color: AC.textSecondary, size: 18),
                                      color: AC.bg3,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      onSelected: (value) async {
                                        if (value == 'toggle') {
                                          await _toggleStatus(user);
                                        } else if (value == 'delete') {
                                          await _deleteUser(user);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'toggle',
                                          child: Row(
                                            children: [
                                              Icon(
                                                user.status == UserStatus.active
                                                    ? Icons.block_rounded
                                                    : Icons
                                                        .check_circle_rounded,
                                                color: user.status ==
                                                        UserStatus.active
                                                    ? AC.orange
                                                    : AC.green,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                user.status == UserStatus.active
                                                    ? 'Suspend'
                                                    : 'Activate',
                                                style: AT.body.copyWith(
                                                  color: user.status ==
                                                          UserStatus.active
                                                      ? AC.orange
                                                      : AC.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.redAccent,
                                                  size: 18),
                                              const SizedBox(width: 10),
                                              Text('Delete',
                                                  style: AT.body.copyWith(
                                                      color: Colors.redAccent)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _toggleStatus(AppUser user) async {
    final isActive = user.status == UserStatus.active;
    final confirm = await showConfirmDialog(
      context,
      title: isActive ? 'Suspend ${user.name}?' : 'Activate ${user.name}?',
      message: isActive
          ? 'This will prevent the user from accessing their account.'
          : 'This will restore full access to the account.',
      confirmLabel: isActive ? 'Suspend' : 'Activate',
      confirmColor: isActive ? AC.orange : AC.green,
      icon: isActive ? Icons.block_rounded : Icons.check_circle_rounded,
    );
    if (!confirm || !mounted) return;

    user.status = isActive ? UserStatus.suspended : UserStatus.active;
    await DB.updateUser(user);
    if (mounted) setState(() {});
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete ${user.name}?',
      message:
          'This permanently removes the user account and all associated data from Firestore.',
      confirmLabel: 'Delete',
      confirmColor: AC.red,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirm || !mounted) return;

    await DB.deleteUser(user.email);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} deleted.'),
          backgroundColor: AC.bg3,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: cardDecor(border: tone.withOpacity(0.16)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tone, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: tone)),
                Text(label, style: AT.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  Color get _color {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return AC.pink;
    if (lower.contains('organizer') || lower.contains('manager')) {
      return AC.violet;
    }
    return AC.cyan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Text(
        role.toUpperCase(),
        style: AT.label.copyWith(color: _color, fontSize: 9),
      ),
    );
  }
}
