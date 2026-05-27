import 'package:flutter/material.dart';

import 'core_shared.dart';

class AdminOverviewView extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const AdminOverviewView({
    super.key,
    this.onNavigate,
  });

  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _fadeAnims = [];
  final List<Animation<Offset>> _slideAnims = [];

  static const int _sectionCount = 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    for (int i = 0; i < _sectionCount; i++) {
      final start = (i * 0.07).clamp(0.0, 0.85);
      final end = (start + 0.38).clamp(0.0, 1.0);
      final interval = Interval(start, end, curve: Curves.easeOutCubic);

      _fadeAnims.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: interval),
        ),
      );
      _slideAnims.add(
        Tween<Offset>(
          begin: const Offset(0, 0.28),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: interval),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    final i = index.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: _fadeAnims[i],
      child: SlideTransition(position: _slideAnims[i], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTournaments = DB.tournaments.length;
    final liveTournaments = DB.tournaments
        .where((tournament) => tournament.status == TourStatus.live)
        .length;
    final totalUsers = DB.users.length;
    final archivedTournaments =
        DB.tournaments.where((tournament) => tournament.isArchived).length;
    final spotlight = DB.tournaments.firstWhere(
      (tournament) => !tournament.isArchived,
      orElse: () => DB.tournaments.first,
    );
    final pendingTeams = DB.tournaments
        .expand((tournament) => tournament.registrants.map((team) {
              return MapEntry(tournament, team);
            }))
        .where((entry) => entry.value.state == ApprovalState.pending)
        .toList();

    return ScrollConfiguration(
      behavior: _ClampingScrollBehavior(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _animated(0, const SectionHdr(title: 'PLATFORM SNAPSHOT')),
                const SizedBox(height: 12),
                _animated(
                  1,
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.28,
                    children: [
                      _MetricCard(
                        label: 'Tournaments',
                        value: '$totalTournaments',
                        tone: AC.cyan,
                        icon: Icons.emoji_events_rounded,
                      ),
                      _MetricCard(
                        label: 'Live Now',
                        value: '$liveTournaments',
                        tone: AC.orange,
                        icon: Icons.live_tv_rounded,
                      ),
                      _MetricCard(
                        label: 'Users',
                        value: '$totalUsers',
                        tone: AC.green,
                        icon: Icons.groups_rounded,
                      ),
                      _MetricCard(
                        label: 'Archived',
                        value: '$archivedTournaments',
                        tone: AC.violet,
                        icon: Icons.archive_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _animated(2, const SectionHdr(title: 'TOURNAMENT SPOTLIGHT')),
                const SizedBox(height: 12),
                _animated(
                  3,
                  _SpotlightCard(
                    tournament: spotlight,
                    onTap: () => widget.onNavigate?.call(1),
                  ),
                ),
                const SizedBox(height: 26),
                _animated(
                  4,
                  SectionHdr(
                    title: 'PENDING TEAM REVIEWS',
                    trailing: pendingTeams.isEmpty ? null : 'Open approvals',
                  ),
                ),
                const SizedBox(height: 12),
                if (pendingTeams.isEmpty)
                  _animated(
                    5,
                    const EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'Queue is clear',
                      subtitle:
                          'There are no pending team approvals right now.',
                    ),
                  )
                else
                  ...pendingTeams.take(3).toList().asMap().entries.map(
                        (e) => _animated(
                          5 + e.key,
                          _PendingTeamCard(
                            tournament: e.value.key,
                            team: e.value.value,
                            onTap: () => widget.onNavigate?.call(2),
                          ),
                        ),
                      ),
                const SizedBox(height: 26),
                _animated(8, const SectionHdr(title: 'RECENT USERS')),
                const SizedBox(height: 12),
                ...DB.users.take(3).toList().asMap().entries.map(
                      (e) => _animated(9 + e.key, _UserCard(user: e.value)),
                    ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Forces ClampingScrollPhysics on all scrollables, overrides iOS bounce ────
class _ClampingScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AC.bg3,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AC.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AC.cyan),
            const SizedBox(width: 8),
            Text(
              label,
              style: AT.caption.copyWith(
                color: AC.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecor(border: tone.withOpacity(0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: tone,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: AT.label.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const _SpotlightCard({
    required this.tournament,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: cardDecor(
          border: tourStatusColor(tournament.status).withOpacity(0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tournament.game.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.title,
                        style: AT.heading.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tournament.organizer ?? 'Organizer TBA'} • ${tournament.location ?? 'Location TBA'}',
                        style: AT.caption,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: tournament.status.label,
                  color: tourStatusColor(tournament.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DetailPill(
                  label: 'Prize',
                  value: tournament.prize,
                  tone: AC.gold,
                ),
                const SizedBox(width: 10),
                _DetailPill(
                  label: 'Teams',
                  value:
                      '${tournament.registrants.length}/${tournament.maxTeams}',
                  tone: AC.cyan,
                ),
                const SizedBox(width: 10),
                _DetailPill(
                  label: 'Format',
                  value: tournament.format.label,
                  tone: AC.violet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _DetailPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AC.bg3,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AC.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AT.label.copyWith(fontSize: 9)),
            const SizedBox(height: 6),
            Text(
              value,
              style: AT.body.copyWith(
                color: tone,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTeamCard extends StatelessWidget {
  final Tournament tournament;
  final TeamReg team;
  final VoidCallback? onTap;

  const _PendingTeamCard({
    required this.tournament,
    required this.team,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardDecor(border: AC.gold.withOpacity(0.22)),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AC.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: AC.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.teamName, style: AT.subheading),
                  const SizedBox(height: 3),
                  Text(
                    '${tournament.title} • ${team.region}',
                    style: AT.caption,
                  ),
                ],
              ),
            ),
            StatusBadge(label: 'Pending', color: AC.gold),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final tone = userStatusColor(user.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecor(border: tone.withOpacity(0.18)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: tone.withOpacity(0.12),
            child: Text(
              user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
              style: TextStyle(
                color: tone,
                fontWeight: FontWeight.w800,
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
                Text('${user.role} • ${user.email}', style: AT.caption),
              ],
            ),
          ),
          StatusBadge(label: user.status.label, color: tone),
        ],
      ),
    );
  }
}
