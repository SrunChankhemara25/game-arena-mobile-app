import 'package:flutter/material.dart';

import 'core_shared.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    DB.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = DB.users.where((user) {
      final query = _search.trim().toLowerCase();
      if (query.isEmpty) return true;
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();

    final activeCount =
        DB.users.where((user) => user.status == UserStatus.active).length;
    final suspendedCount =
        DB.users.where((user) => user.status == UserStatus.suspended).length;

    return Column(
      children: [
        // Fixed header — never resizes on scroll
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        'User access, search, and moderation in a tighter mobile list.',
                        style: AT.body.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: AC.textPrimary),
                onChanged: (value) => setState(() => _search = value),
                decoration: fieldDecor(
                  hint: 'Search by name, email, or role',
                  icon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _UserSummaryCard(
                      label: 'Active',
                      value: '$activeCount',
                      tone: AC.green,
                      icon: Icons.verified_user_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _UserSummaryCard(
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

        // Scrollable list — only this part scrolls
        Expanded(
          child: users.isEmpty
              ? const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No users found',
                  subtitle:
                      'Try a different keyword or clear the current search.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: users.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final tone = userStatusColor(user.status);
                    final isActive = user.status == UserStatus.active;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: cardDecor(border: tone.withOpacity(0.18)),
                      child: Row(
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Text(
                                  '${user.role}${user.country != null ? ' • ${user.country}' : ''}',
                                  style: AT.caption.copyWith(
                                    color: AC.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                onSelected: (value) async {
                                  if (value == 'toggle') {
                                    setState(() {
                                      user.status = isActive
                                          ? UserStatus.suspended
                                          : UserStatus.active;
                                    });
                                    await DB.updateUser(user);
                                    if (mounted) setState(() {});
                                  } else if (value == 'delete') {
                                    await _deleteUser(user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'toggle',
                                    child: Text(
                                        isActive ? 'Suspend user' : 'Activate'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
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
      ],
    );
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete ${user.name}?',
      message:
          'This removes the user from the local admin list in this screen.',
      confirmLabel: 'Delete',
      confirmColor: AC.red,
      icon: Icons.delete_outline_rounded,
    );

    if (!confirm) return;

    await DB.deleteUser(user.email);
    if (mounted) setState(() {});
  }
}

class _UserSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final IconData icon;

  const _UserSummaryCard({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecor(border: tone.withOpacity(0.16)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tone, size: 17),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: tone,
                ),
              ),
              Text(label, style: AT.caption),
            ],
          ),
        ],
      ),
    );
  }
}
