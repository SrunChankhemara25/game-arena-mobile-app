import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core_shared.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _search = '';
  bool _loading = true;
  String _statusFilter = 'All';
  bool _searchActive = false;
  StreamSubscription<List<AppUser>>? _usersSub;

  late final AnimationController _shimmerCtrl;

  static const _statusFilterOptions = ['All', 'Active', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    await DB.initialize();
    if (!mounted) return;
    setState(() => _loading = false);
    _usersSub = DB.watchUsers().listen((users) {
      if (!mounted) return;
      DB.users = users;
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await DB.refresh();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _searchCtrl.dispose();
    _usersSub?.cancel();
    super.dispose();
  }

  List<AppUser> get _filtered {
    return DB.users.where((u) {
      // Never show admin accounts
      if (u.role.toLowerCase().contains('admin')) return false;
      final q = _search.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q) ||
          (u.country?.toLowerCase().contains(q) ?? false);
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && u.status == UserStatus.active) ||
          (_statusFilter == 'Suspended' && u.status == UserStatus.suspended);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filtered;
    final nonAdmin =
        DB.users.where((u) => !u.role.toLowerCase().contains('admin')).toList();
    final total = nonAdmin.length;
    final active = nonAdmin.where((u) => u.status == UserStatus.active).length;
    final suspended =
        nonAdmin.where((u) => u.status == UserStatus.suspended).length;

    return Column(
      children: [
        _buildHeader(total, active, suspended),
        _buildFilterRow(),
        Expanded(
          child: _loading
              ? _buildSkeletonList()
              : users.isEmpty
                  ? _buildEmptyState()
                  : _buildUserList(users),
        ),
      ],
    );
  }

  Widget _buildHeader(int total, int active, int suspended) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AC.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('$total registered users', style: AT.caption),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _refresh,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AC.bg3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AC.border),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: AC.cyan, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _searchActive = !_searchActive;
                    if (!_searchActive) {
                      _searchCtrl.clear();
                      _search = '';
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _searchActive
                        ? AC.cyan.withValues(alpha: 0.15)
                        : AC.bg3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _searchActive
                          ? AC.cyan.withValues(alpha: 0.5)
                          : AC.border,
                    ),
                  ),
                  child: Icon(
                    _searchActive ? Icons.close_rounded : Icons.search_rounded,
                    color: _searchActive ? AC.cyan : AC.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatPill(label: 'Total', value: '$total', color: AC.cyan),
              const SizedBox(width: 8),
              _StatPill(label: 'Active', value: '$active', color: AC.green),
              const SizedBox(width: 8),
              _StatPill(label: 'Suspended', value: '$suspended', color: AC.red),
            ],
          ),
          const SizedBox(height: 14),

          // Collapsible search bar
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _searchActive
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AC.bg3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AC.cyan.withValues(alpha: 0.4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AC.cyan, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: const TextStyle(
                            color: AC.textPrimary, fontSize: 14),
                        onChanged: (v) => setState(() => _search = v),
                        cursorColor: AC.cyan,
                        decoration: InputDecoration(
                          hintText: 'Search name, email, role, country…',
                          hintStyle: AT.caption.copyWith(color: AC.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_search.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                        child: const Icon(Icons.cancel_rounded,
                            color: AC.textMuted, size: 16),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: _statusFilterOptions
            .map(
              (s) => _FilterChip(
                label: s,
                isActive: _statusFilter == s,
                color: s == 'Active'
                    ? AC.green
                    : s == 'Suspended'
                        ? AC.red
                        : AC.cyan,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _statusFilter = s);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildUserList(List<AppUser> users) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AC.cyan,
      backgroundColor: AC.bg2,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(
            user: user,
            index: index,
            onToggleStatus: () => _toggleStatus(user),
            onDelete: () => _deleteUser(user),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final shimmerColor = Color.lerp(
          AC.bg2,
          AC.bg4,
          math.sin(_shimmerCtrl.value * math.pi),
        )!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AC.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 13,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 11,
                        width: 160,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AC.bg3,
              shape: BoxShape.circle,
              border: Border.all(color: AC.border),
            ),
            child: const Icon(Icons.person_search_rounded,
                color: AC.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            _search.isNotEmpty ? 'No results for "$_search"' : 'No users found',
            style: AT.heading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text('Try adjusting your filters or search term.',
              style: AT.caption),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() {
                _search = '';
                _statusFilter = 'All';
                _searchActive = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AC.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AC.cyan.withValues(alpha: 0.3)),
              ),
              child: Text('Clear Filters',
                  style: AT.label.copyWith(color: AC.cyan)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(AppUser user) async {
    HapticFeedback.mediumImpact();
    final isActive = user.status == UserStatus.active;
    final confirm = await showConfirmDialog(
      context,
      title: isActive ? 'Suspend ${user.name}?' : 'Activate ${user.name}?',
      message: isActive
          ? 'This prevents the user from accessing their account.'
          : 'This restores full access to the account.',
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
    HapticFeedback.heavyImpact();
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete ${user.name}?',
      message:
          'This permanently removes the account and all associated data. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AC.red,
      icon: Icons.delete_forever_rounded,
    );
    if (!confirm || !mounted) return;
    await DB.deleteUser(user.email);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AC.green, size: 16),
              const SizedBox(width: 10),
              Text('${user.name} permanently deleted.'),
            ],
          ),
          backgroundColor: AC.bg3,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }
}

// ── User Card ─────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final AppUser user;
  final int index;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.index,
    required this.onToggleStatus,
    required this.onDelete,
  });

  Color get _roleColor {
    final r = user.role.toLowerCase();
    if (r.contains('admin')) return AC.pink;
    if (r.contains('organizer') || r.contains('manager')) return AC.violet;
    return AC.cyan;
  }

  Color get _statusColor =>
      user.status == UserStatus.active ? AC.green : AC.red;

  String get _initials => compactInitials(user.name, maxChars: 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AC.gradCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: user.status == UserStatus.suspended
              ? AC.red.withValues(alpha: 0.2)
              : AC.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _roleColor,
                      _roleColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  // Avatar with status dot
                  Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _roleColor.withValues(alpha: 0.25),
                              _roleColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _roleColor.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: TextStyle(
                              color: _roleColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AC.bg2, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AC.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          style: AT.caption.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _Badge(
                                label: user.role.toUpperCase(),
                                color: _roleColor),
                            if (user.country != null &&
                                user.country!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _Badge(
                                label: user.country!,
                                color: AC.textMuted,
                                icon: Icons.location_on_rounded,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status + menu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              user.status.label.toUpperCase(),
                              style: AT.label
                                  .copyWith(color: _statusColor, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AC.textMuted, size: 20),
                        color: AC.bg3,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AC.border),
                        ),
                        offset: const Offset(-10, 8),
                        onSelected: (v) {
                          if (v == 'toggle') onToggleStatus();
                          if (v == 'delete') onDelete();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: user.status == UserStatus.active
                                        ? AC.orange.withValues(alpha: 0.12)
                                        : AC.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    user.status == UserStatus.active
                                        ? Icons.block_rounded
                                        : Icons.check_circle_rounded,
                                    color: user.status == UserStatus.active
                                        ? AC.orange
                                        : AC.green,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  user.status == UserStatus.active
                                      ? 'Suspend User'
                                      : 'Activate User',
                                  style: AT.body.copyWith(
                                    color: user.status == UserStatus.active
                                        ? AC.orange
                                        : AC.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AC.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: AC.red,
                                      size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text('Delete Permanently',
                                    style: AT.body.copyWith(color: AC.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AT.label
                  .copyWith(fontSize: 9, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : AC.bg3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : AC.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : AC.textMuted,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AT.label.copyWith(color: color, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
