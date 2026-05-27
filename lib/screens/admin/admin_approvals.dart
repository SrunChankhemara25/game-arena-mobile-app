import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core_shared.dart';

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView> {
  GameCtx? _selectedGame;
  Tournament? _selectedTournament;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ApprovalBreadcrumb(
          game: _selectedGame,
          tournament: _selectedTournament,
          onResetGames: () => setState(() {
            _selectedGame = null;
            _selectedTournament = null;
          }),
          onResetTournaments: () => setState(() => _selectedTournament = null),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              // Slide from right on forward, slide from left on back
              final offsetTween = Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              );
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position: offsetTween.animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
            child: _selectedGame == null
                ? _GameSelection(
                    key: const ValueKey('games'),
                    onSelect: (game) => setState(() => _selectedGame = game),
                  )
                : _selectedTournament == null
                    ? _TournamentSelection(
                        key: const ValueKey('tournaments'),
                        game: _selectedGame!,
                        onSelect: (tournament) =>
                            setState(() => _selectedTournament = tournament),
                      )
                    : _TeamReviewList(
                        key: const ValueKey('teams'),
                        tournament: _selectedTournament!,
                        onChanged: () => setState(() {}),
                        onOpenDetail: (team) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminApprovalTeamDetailScreen(
                                tournament: _selectedTournament!,
                                team: team,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
          ),
        ),
      ],
    );
  }
}

// ─── Breadcrumb ───────────────────────────────────────────────────────────────
class _ApprovalBreadcrumb extends StatelessWidget {
  final GameCtx? game;
  final Tournament? tournament;
  final VoidCallback onResetGames;
  final VoidCallback onResetTournaments;

  const _ApprovalBreadcrumb({
    required this.game,
    required this.tournament,
    required this.onResetGames,
    required this.onResetTournaments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: const BoxDecoration(
        color: AC.bg0,
        border: Border(bottom: BorderSide(color: AC.border)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _Crumb(
            label: 'Games',
            active: game == null,
            onTap: onResetGames,
          ),
          if (game != null) ...[
            const Icon(Icons.chevron_right_rounded,
                color: AC.textMuted, size: 18),
            _Crumb(
              label: '${game!.emoji} ${game!.label}',
              active: tournament == null,
              onTap: onResetTournaments,
            ),
          ],
          if (tournament != null) ...[
            const Icon(Icons.chevron_right_rounded,
                color: AC.textMuted, size: 18),
            _Crumb(
              label: tournament!.title,
              active: true,
              onTap: onResetTournaments,
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Crumb({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AC.cyan.withOpacity(0.12) : AC.bg2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AC.cyan.withOpacity(0.24) : AC.border,
          ),
        ),
        child: Text(
          label,
          style: AT.caption.copyWith(
            color: active ? AC.cyan : AC.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Game Selection ───────────────────────────────────────────────────────────
class _GameSelection extends StatefulWidget {
  final ValueChanged<GameCtx> onSelect;

  const _GameSelection({
    super.key,
    required this.onSelect,
  });

  @override
  State<_GameSelection> createState() => _GameSelectionState();
}

class _GameSelectionState extends State<_GameSelection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = GameCtx.values;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final tournaments = DB.tournaments
            .where((tournament) => tournament.game == game)
            .toList();
        final pending = tournaments.fold<int>(
          0,
          (count, tournament) => count + tournament.pendingCount,
        );

        final delay = (index * 0.07).clamp(0.0, 0.7);
        final itemAnim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: itemAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 28 * (1 - itemAnim.value)),
            child: Opacity(opacity: itemAnim.value, child: child),
          ),
          child: GestureDetector(
            onTap: tournaments.isEmpty ? null : () => widget.onSelect(game),
            child: Opacity(
              opacity: tournaments.isEmpty ? 0.55 : 1,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: cardDecor(
                  border: tournaments.isEmpty
                      ? AC.border
                      : AC.pink.withOpacity(0.16),
                ),
                child: Row(
                  children: [
                    AdminLogoBadge(
                      imageUrl: defaultGameLogoUrl(game),
                      fallback: game.label,
                      size: 46,
                      radius: 14,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(game.label, style: AT.subheading),
                          const SizedBox(height: 4),
                          Text(
                            '${tournaments.length} tournaments • $pending pending approvals',
                            style: AT.caption,
                          ),
                        ],
                      ),
                    ),
                    if (pending > 0)
                      StatusBadge(label: '$pending', color: AC.gold),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded,
                        color: AC.textMuted, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tournament Selection ─────────────────────────────────────────────────────
class _TournamentSelection extends StatefulWidget {
  final GameCtx game;
  final ValueChanged<Tournament> onSelect;

  const _TournamentSelection({
    super.key,
    required this.game,
    required this.onSelect,
  });

  @override
  State<_TournamentSelection> createState() => _TournamentSelectionState();
}

class _TournamentSelectionState extends State<_TournamentSelection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = DB.tournaments
        .where((tournament) => tournament.game == widget.game)
        .toList();

    if (tournaments.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No tournaments',
        subtitle: 'There are no tournaments registered for this game yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];

        final delay = (index * 0.07).clamp(0.0, 0.7);
        final itemAnim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: itemAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 28 * (1 - itemAnim.value)),
            child: Opacity(opacity: itemAnim.value, child: child),
          ),
          child: GestureDetector(
            onTap: () => widget.onSelect(tournament),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: cardDecor(
                border: tourStatusColor(tournament.status).withOpacity(0.18),
              ),
              child: Row(
                children: [
                  AdminLogoBadge(
                    imageUrl: tournament.resolvedLogoUrl,
                    fallback: tournament.game.label,
                    size: 46,
                    radius: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AT.subheading,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tournament.registrants.length} teams • ${tournament.prize}',
                          style: AT.caption,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            StatusBadge(
                              label: tournament.status.label,
                              color: tourStatusColor(tournament.status),
                            ),
                            if (tournament.pendingCount > 0)
                              StatusBadge(
                                label: '${tournament.pendingCount} pending',
                                color: AC.gold,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AC.textMuted, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Team Review List ─────────────────────────────────────────────────────────
class _TeamReviewList extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback onChanged;
  final ValueChanged<TeamReg> onOpenDetail;

  const _TeamReviewList({
    super.key,
    required this.tournament,
    required this.onChanged,
    required this.onOpenDetail,
  });

  @override
  State<_TeamReviewList> createState() => _TeamReviewListState();
}

class _TeamReviewListState extends State<_TeamReviewList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teams = widget.tournament.registrants;

    if (teams.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        title: 'No registrations yet',
        subtitle: 'Teams will appear here after they submit their lineup.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final tone = approvalColor(team.state);

        final delay = (index * 0.07).clamp(0.0, 0.7);
        final itemAnim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: itemAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 28 * (1 - itemAnim.value)),
            child: Opacity(opacity: itemAnim.value, child: child),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: cardDecor(border: tone.withOpacity(0.18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.onOpenDetail(team),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: tone.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            team.teamName.isEmpty
                                ? '?'
                                : team.teamName[0].toUpperCase(),
                            style: TextStyle(
                              color: tone,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(team.teamName, style: AT.subheading),
                            const SizedBox(height: 4),
                            Text(
                              '${team.region} • ${team.lineupCount} players',
                              style: AT.caption,
                            ),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: StatusBadge(
                          key: ValueKey(team.state),
                          label: team.state.label,
                          color: tone,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _CompactApprovalLineup(team: team),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlineBtn(
                        label: 'Details',
                        icon: Icons.visibility_rounded,
                        onTap: () => widget.onOpenDetail(team),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (team.state == ApprovalState.pending) ...[
                      Expanded(
                        child: OutlineBtn(
                          label: 'Reject',
                          color: AC.red,
                          icon: Icons.close_rounded,
                          onTap: () {
                            setState(() => team.state = ApprovalState.rejected);
                            widget.onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GradButton(
                          label: 'Approve',
                          icon: Icons.check_rounded,
                          onTap: () {
                            setState(() => team.state = ApprovalState.approved);
                            widget.onChanged();
                          },
                        ),
                      ),
                    ] else
                      Expanded(
                        child: OutlineBtn(
                          label: 'Undo Action',
                          color: AC.textSecondary,
                          icon: Icons.undo_rounded,
                          onTap: () {
                            setState(() => team.state = ApprovalState.pending);
                            widget.onChanged();
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Compact Approval Lineup ──────────────────────────────────────────────────
class _CompactApprovalLineup extends StatelessWidget {
  final TeamReg team;

  const _CompactApprovalLineup({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final rosterPreview = team.roster.take(3).join(' • ');
    final extraCount = team.roster.length - math.min(team.roster.length, 3);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LINEUP', style: AT.label),
          const SizedBox(height: 6),
          Text(
            extraCount > 0
                ? '$rosterPreview  •  +$extraCount more'
                : rosterPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AT.body.copyWith(color: AC.textPrimary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Coach: ${team.coach?.trim().isNotEmpty == true ? team.coach : 'Not set'}',
                  style: AT.caption.copyWith(color: AC.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  'Assistant: ${team.assistantCoach?.trim().isNotEmpty == true ? team.assistantCoach : 'Not set'}',
                  style: AT.caption.copyWith(color: AC.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Lineup Identity Board ────────────────────────────────────────────────────
class _LineupIdentityBoard extends StatelessWidget {
  final TeamReg team;

  const _LineupIdentityBoard({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AC.bg0.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHdr(title: 'LINEUP IDENTITY'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROSTER PLAYERS', style: AT.label),
                    const SizedBox(height: 10),
                    ...team.roster.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final player = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AC.bg3,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AC.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AC.cyan.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: AT.caption.copyWith(
                                    color: AC.cyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                player,
                                style: AT.body.copyWith(
                                  color: AC.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STAFF', style: AT.label),
                    const SizedBox(height: 10),
                    _StaffTile(
                      title: 'Coach',
                      value: team.coach,
                      tone: AC.green,
                    ),
                    const SizedBox(height: 8),
                    _StaffTile(
                      title: 'Assistant',
                      value: team.assistantCoach,
                      tone: AC.cyan,
                    ),
                    const SizedBox(height: 8),
                    _StaffTile(
                      title: 'Manager',
                      value: team.manager,
                      tone: AC.violet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final String title;
  final String? value;
  final Color tone;

  const _StaffTile({
    required this.title,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AC.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AT.label.copyWith(fontSize: 9)),
          const SizedBox(height: 6),
          Text(
            (value == null || value!.trim().isEmpty) ? 'Not provided' : value!,
            style: AT.body.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Detail Screen ───────────────────────────────────────────────────────
class AdminApprovalTeamDetailScreen extends StatefulWidget {
  final Tournament tournament;
  final TeamReg team;

  const AdminApprovalTeamDetailScreen({
    super.key,
    required this.tournament,
    required this.team,
  });

  @override
  State<AdminApprovalTeamDetailScreen> createState() =>
      _AdminApprovalTeamDetailScreenState();
}

class _AdminApprovalTeamDetailScreenState
    extends State<AdminApprovalTeamDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final tone = approvalColor(team.state);

    return Scaffold(
      backgroundColor: AC.bg1,
      appBar: AppBar(
        backgroundColor: AC.bg0,
        surfaceTintColor: Colors.transparent,
        title: Text(team.teamName, style: AT.heading),
        leading: const BackButton(color: AC.cyan),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: cardDecor(
                radius: 28,
                elevated: true,
                border: tone.withOpacity(0.22),
                gradient: AC.gradHero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: tone.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tone.withOpacity(0.28)),
                        ),
                        child: Center(
                          child: Text(
                            team.teamName.isEmpty
                                ? '?'
                                : team.teamName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: tone,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(team.teamName,
                                style: AT.display.copyWith(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.tournament.title} • ${team.region}',
                              style: AT.body,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: StatusBadge(
                          key: ValueKey(team.state),
                          label: team.state.label,
                          color: tone,
                        ),
                      ),
                      StatusBadge(
                        label: '${team.lineupCount} players',
                        color: AC.cyan,
                      ),
                      StatusBadge(
                        label: widget.tournament.game.label,
                        color: AC.violet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _LineupIdentityBoard(team: team),
            const SizedBox(height: 24),
            const SectionHdr(title: 'ADMIN NOTE'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: cardDecor(),
              child: Text(
                team.note?.trim().isNotEmpty == true
                    ? team.note!
                    : 'No additional note was added to this registration.',
                style: AT.body,
              ),
            ),
            const SizedBox(height: 24),
            const SectionHdr(title: 'ACTIONS'),
            Row(
              children: [
                if (team.state != ApprovalState.rejected) ...[
                  Expanded(
                    child: OutlineBtn(
                      label: 'Reject',
                      color: AC.red,
                      icon: Icons.close_rounded,
                      onTap: () => setState(() {
                        team.state = ApprovalState.rejected;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (team.state != ApprovalState.approved)
                  Expanded(
                    child: GradButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      onTap: () => setState(() {
                        team.state = ApprovalState.approved;
                      }),
                    ),
                  )
                else
                  Expanded(
                    child: OutlineBtn(
                      label: 'Undo to Pending',
                      color: AC.textSecondary,
                      icon: Icons.undo_rounded,
                      onTap: () => setState(() {
                        team.state = ApprovalState.pending;
                      }),
                    ),
                  ),
              ],
            ),
            if (team.state == ApprovalState.rejected) ...[
              const SizedBox(height: 12),
              OutlineBtn(
                label: 'Undo to Pending',
                color: AC.textSecondary,
                icon: Icons.undo_rounded,
                onTap: () => setState(() {
                  team.state = ApprovalState.pending;
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
