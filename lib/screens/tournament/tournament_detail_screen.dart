import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common/widgets.dart';
import '../team/team_detail_screen.dart';

// ─── Tournament Detail Screen ─────────────────────────────────────────────────
class TournamentDetailScreen extends StatefulWidget {
  final TournamentModel tournament;
  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  static const _tabs = [
    'OVERVIEW',
    'TEAMS',
    'SCHEDULE',
    'BRACKET',
    'STANDINGS'
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _tab.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppColors.bg0,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.share_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: _TournamentHero(tournament: t),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg0,
                  border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.cyan,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                  labelStyle: AppText.btnSm.copyWith(
                      color: AppColors.cyan, fontSize: 11, letterSpacing: 1.5),
                  unselectedLabelStyle: AppText.btnSm.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      letterSpacing: 1.5),
                  tabs: _tabs.map((l) => Tab(text: l)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _OverviewTab(tournament: t),
            _TeamsTab(tournament: t),
            _ScheduleTab(tournament: t),
            _BracketTab(tournament: t),
            _StandingsTab(tournament: t),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _TournamentHero extends StatelessWidget {
  final TournamentModel tournament;
  const _TournamentHero({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg2, AppColors.bg0],
          stops: [0.0, 0.85],
        ),
      ),
      child: Stack(children: [
        // Decorative grid lines
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        // Ghost emoji
        Positioned(
          right: -16,
          bottom: 40,
          child: Opacity(
            opacity: 0.06,
            child: Text(t.game.emoji, style: const TextStyle(fontSize: 160)),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 72, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Status + game
              Row(children: [
                _HeroBadge(
                  label: _statusLabel(t.status),
                  color: _statusColor(t.status),
                ),
                const SizedBox(width: 8),
                _HeroBadge(
                  label: '${t.game.emoji}  ${t.game.label.toUpperCase()}',
                  color: AppColors.textMuted,
                  textColor: AppColors.textSecondary,
                ),
              ]),
              const SizedBox(height: 10),
              // Title
              Text(t.title,
                  style: AppText.displayMd
                      .copyWith(letterSpacing: 0.3, height: 1.15)),
              const SizedBox(height: 4),
              if (t.organizer != null)
                Text('Organized by ${t.organizer}',
                    style: AppText.body
                        .copyWith(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              // Stat Pills row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _StatPill(
                    icon: Icons.emoji_events_rounded,
                    value: t.prizePoolDisplay,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.groups_rounded,
                    value: '${t.registeredTeams}/${t.maxTeams} teams',
                    color: AppColors.cyan,
                  ),
                  if (t.location != null) ...[
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.location_on_rounded,
                      value: t.location!,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String _statusLabel(TournamentStatus s) => switch (s) {
        TournamentStatus.ongoing => 'ONGOING',
        TournamentStatus.registration => 'REGISTRATION OPEN',
        TournamentStatus.upcoming => 'UPCOMING',
        _ => 'CLOSED',
      };

  Color _statusColor(TournamentStatus s) => switch (s) {
        TournamentStatus.ongoing => AppColors.cyan,
        TournamentStatus.registration => AppColors.green,
        TournamentStatus.upcoming => AppColors.gold,
        _ => AppColors.textMuted,
      };
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _HeroBadge({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(label,
            style: AppText.label.copyWith(
                color: textColor ?? color, fontSize: 10, letterSpacing: 0.8)),
      );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _StatPill(
      {required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(value,
              style: AppText.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.cyan),
            const SizedBox(width: 7),
          ],
          Text(title,
              style: AppText.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.textSecondary)),
        ]),
      );
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final TournamentModel tournament;
  const _OverviewTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stat Cards
        Row(children: [
          Expanded(
              child: _MiniStatCard(
                  label: 'PRIZE POOL',
                  value: t.prizePoolDisplay,
                  valueColor: AppColors.gold,
                  icon: Icons.emoji_events_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStatCard(
                  label: 'TEAMS',
                  value: '${t.registeredTeams}/${t.maxTeams}',
                  icon: Icons.groups_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStatCard(
                  label: 'FORMAT',
                  value: _formatShort(t.format),
                  icon: Icons.account_tree_rounded)),
        ]),
        const SizedBox(height: 28),

        // About
        const _SectionHeader(
            title: 'ABOUT THIS TOURNAMENT', icon: Icons.info_outline_rounded),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor(),
          child: Text(t.description ?? 'No description available.',
              style: AppText.body.copyWith(height: 1.7)),
        ),
        const SizedBox(height: 28),

        // Details
        const _SectionHeader(title: 'DETAILS', icon: Icons.list_alt_rounded),
        Container(
          decoration: _cardDecor(),
          child: Column(children: [
            _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Start',
                value: t.startDateDisplay),
            _DetailRow(
                icon: Icons.calendar_month_rounded,
                label: 'End',
                value: t.endDateDisplay),
            _DetailRow(
                icon: Icons.timer_outlined,
                label: 'Reg. Deadline',
                value: t.registrationDeadlineDisplay),
            _DetailRow(
                icon: Icons.location_on_rounded,
                label: 'Location',
                value: t.location ?? 'TBA'),
            _DetailRow(
                icon: Icons.account_tree_rounded,
                label: 'Format',
                value: _formatLabel(t.format)),
            _DetailRow(
                icon: Icons.business_rounded,
                label: 'Organizer',
                value: t.organizer ?? 'TBA',
                isLast: true),
          ]),
        ),

        if (t.status == TournamentStatus.registration) ...[
          const SizedBox(height: 28),
          GlowButton(
            label: 'REGISTER YOUR TEAM',
            width: double.infinity,
            icon: Icons.add_circle_outline_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => _RegisterTeamScreen(tournament: t)),
              );
            },
          ),
        ],
        const SizedBox(height: 20),
      ]),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      );

  String _formatShort(TournamentFormat f) => switch (f) {
        TournamentFormat.singleElim => 'SE',
        TournamentFormat.doubleElim => 'DE',
        TournamentFormat.groupStage => 'GS',
        TournamentFormat.groupAndElim => 'G+E',
        TournamentFormat.roundRobin => 'RR',
      };

  String _formatLabel(TournamentFormat f) => switch (f) {
        TournamentFormat.singleElim => 'Single Elimination',
        TournamentFormat.doubleElim => 'Double Elimination',
        TournamentFormat.groupStage => 'Group Stage',
        TournamentFormat.groupAndElim => 'Group Stage + Playoffs',
        TournamentFormat.roundRobin => 'Round Robin',
      };
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData icon;
  const _MiniStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(height: 6),
          Text(value,
              style: AppText.heading.copyWith(
                  fontSize: 15, color: valueColor ?? AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: AppText.label.copyWith(
                  fontSize: 9, letterSpacing: 1, color: AppColors.textMuted)),
        ]),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(label,
                style:
                    AppText.caption.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text(value, style: AppText.bodyMd.copyWith(fontSize: 13)),
          ]),
        ),
        if (!isLast)
          Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 40),
              color: AppColors.border),
      ]);
}

// ─── Teams Tab ────────────────────────────────────────────────────────────────
class _TeamsTab extends StatelessWidget {
  final TournamentModel tournament;
  const _TeamsTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (tournament.teams.isEmpty) {
      return const EmptyState(
          icon: Icons.groups_rounded,
          title: 'No Teams Yet',
          subtitle: 'Be the first to register your team');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tournament.teams.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SectionHeader(
                title: '${tournament.teams.length} REGISTERED TEAMS'),
          );
        }
        final team = tournament.teams[i - 1];
        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => TeamDetailScreen(team: team))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              // Rank
              SizedBox(
                width: 24,
                child: Text('${i}',
                    style: AppText.label
                        .copyWith(color: AppColors.textMuted, fontSize: 12)),
              ),
              const SizedBox(width: 4),
              TeamAvatar(team: team, size: 44),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Flexible(
                        child: Text(team.name,
                            style: AppText.heading.copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      _TeamStatusPill(status: team.status),
                    ]),
                    const SizedBox(height: 5),
                    Text('${team.players.length} members · ${team.country}',
                        style: AppText.caption),
                  ])),
              // W/L
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  Text('${team.wins}',
                      style: AppText.heading
                          .copyWith(fontSize: 14, color: AppColors.green)),
                  Text('W',
                      style: AppText.caption.copyWith(color: AppColors.green)),
                  const SizedBox(width: 8),
                  Text('${team.losses}',
                      style: AppText.heading
                          .copyWith(fontSize: 14, color: AppColors.red)),
                  Text('L',
                      style: AppText.caption.copyWith(color: AppColors.red)),
                ]),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 16),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _TeamStatusPill extends StatelessWidget {
  final TeamStatus status;
  const _TeamStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TeamStatus.approved => (AppColors.green, 'APPROVED'),
      TeamStatus.pending => (AppColors.gold, 'PENDING'),
      _ => (AppColors.red, 'REJECTED'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child:
          Text(label, style: AppText.label.copyWith(color: color, fontSize: 9)),
    );
  }
}

// ─── Schedule Tab ─────────────────────────────────────────────────────────────
class _ScheduleTab extends StatelessWidget {
  final TournamentModel tournament;
  const _ScheduleTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (tournament.matches.isEmpty) {
      return const EmptyState(
          icon: Icons.schedule_rounded,
          title: 'No Matches Yet',
          subtitle: 'Schedule will be posted soon');
    }

    final grouped = <String, List<MatchModel>>{};
    for (final m in tournament.matches) {
      (grouped[m.round] ??= []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: grouped.entries
          .map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: e.key.toUpperCase()),
                  ...e.value
                      .map((m) => _MatchCard(match: m, tournament: tournament)),
                  const SizedBox(height: 12),
                ],
              ))
          .toList(),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final TournamentModel tournament;
  const _MatchCard({required this.match, required this.tournament});

  TeamModel? _findTeam(String? id) =>
      id == null ? null : tournament.teams.where((t) => t.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final t1 = _findTeam(match.team1Id);
    final t2 = _findTeam(match.team2Id);
    final isLive = match.status == 'live';
    final isDone = match.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive ? AppColors.red.withOpacity(0.5) : AppColors.border,
          width: isLive ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        // Match meta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            const Icon(Icons.access_time_rounded,
                size: 11, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(match.scheduledAt ?? 'TBA', style: AppText.caption),
            const Spacer(),
            _MatchStatusPill(status: match.status),
          ]),
        ),
        Container(height: 0.5, color: AppColors.border),
        // Scores
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Expanded(
                child: _TeamScoreWidget(
                    team: t1,
                    score: match.score1,
                    isWinner: match.winnerId == match.team1Id,
                    align: CrossAxisAlignment.start)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(children: [
                Text(
                  isDone ? '${match.score1}  —  ${match.score2}' : 'VS',
                  style: isDone
                      ? AppText.heading.copyWith(
                          fontSize: 18,
                          letterSpacing: 2,
                          color: AppColors.textPrimary)
                      : AppText.label.copyWith(
                          fontSize: 13,
                          letterSpacing: 3,
                          color: AppColors.textMuted),
                ),
              ]),
            ),
            Expanded(
                child: _TeamScoreWidget(
                    team: t2,
                    score: match.score2,
                    isWinner: match.winnerId == match.team2Id,
                    align: CrossAxisAlignment.end)),
          ]),
        ),
      ]),
    );
  }
}

class _TeamScoreWidget extends StatelessWidget {
  final TeamModel? team;
  final int score;
  final bool isWinner;
  final CrossAxisAlignment align;
  const _TeamScoreWidget(
      {required this.team,
      required this.score,
      required this.isWinner,
      required this.align});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: align,
        children: [
          if (team != null) ...[
            TeamAvatar(team: team!, size: 36),
            const SizedBox(height: 6),
            Text(
              team!.name.split(' ').first,
              style: AppText.caption.copyWith(
                  color: isWinner
                      ? AppColors.textPrimary
                      : AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isWinner)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.green.withOpacity(0.3)),
                  ),
                  child: Text('WIN',
                      style: AppText.label
                          .copyWith(color: AppColors.green, fontSize: 9)),
                ),
              ),
          ] else ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                  child: Icon(Icons.question_mark_rounded,
                      size: 14, color: AppColors.textMuted)),
            ),
            const SizedBox(height: 6),
            Text('TBD',
                style: AppText.caption.copyWith(color: AppColors.textMuted)),
          ],
        ],
      );
}

class _MatchStatusPill extends StatelessWidget {
  final String status;
  const _MatchStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'live' => (AppColors.cyan, 'ONGOING'),
      'completed' => (AppColors.green, '✓ DONE'),
      _ => (AppColors.textMuted, 'UPCOMING'),
    };
    return Text(label,
        style: AppText.label.copyWith(color: color, fontSize: 10));
  }
}

// ─── Bracket Tab ─────────────────────────────────────────────────────────────
class _BracketTab extends StatelessWidget {
  final TournamentModel tournament;
  const _BracketTab({required this.tournament});

  static const _rounds = [
    'Group Stage - Week 1',
    'Group Stage - Week 2',
    'Semi Final',
    'Grand Final',
  ];

  @override
  Widget build(BuildContext context) {
    if (tournament.matches.isEmpty) {
      return const EmptyState(
          icon: Icons.account_tree_rounded,
          title: 'Bracket Not Available',
          subtitle: 'The bracket will be generated after registration closes');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _rounds.asMap().entries.map((e) {
            final roundMatches = tournament.matches
                .where((m) =>
                    m.round.startsWith(e.value.split(' - ').first) ||
                    m.round == e.value)
                .toList();
            return _BracketColumn(
              round: e.value,
              matches: roundMatches,
              tournament: tournament,
              isLast: e.key == _rounds.length - 1,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BracketColumn extends StatelessWidget {
  final String round;
  final List<MatchModel> matches;
  final TournamentModel tournament;
  final bool isLast;
  const _BracketColumn(
      {required this.round,
      required this.matches,
      required this.tournament,
      required this.isLast});

  TeamModel? _findTeam(String? id) =>
      id == null ? null : tournament.teams.where((t) => t.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) => Row(children: [
        Column(children: [
          Container(
            width: 156,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(round,
                style: AppText.label.copyWith(
                    color: AppColors.cyan, fontSize: 10, letterSpacing: 1),
                textAlign: TextAlign.center,
                maxLines: 2),
          ),
          if (matches.isEmpty)
            _BracketSlot(team: null, isWinner: false, label: 'TBD')
          else
            ...matches.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(children: [
                    _BracketSlot(
                        team: _findTeam(m.team1Id),
                        isWinner: m.winnerId == m.team1Id),
                    Container(height: 0.5, width: 156, color: AppColors.border),
                    _BracketSlot(
                        team: _findTeam(m.team2Id),
                        isWinner: m.winnerId == m.team2Id),
                  ]),
                )),
        ]),
        if (!isLast)
          const SizedBox(
            width: 28,
            height: 40,
            child: Center(
              child: Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.border),
            ),
          ),
      ]);
}

class _BracketSlot extends StatelessWidget {
  final TeamModel? team;
  final bool isWinner;
  final String? label;
  const _BracketSlot({required this.team, required this.isWinner, this.label});

  @override
  Widget build(BuildContext context) => Container(
        width: 156,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isWinner ? AppColors.cyan.withOpacity(0.08) : AppColors.bg2,
          border: Border.all(
              color: isWinner
                  ? AppColors.cyan.withOpacity(0.4)
                  : AppColors.border),
        ),
        child: Row(children: [
          if (team != null) ...[
            TeamAvatar(team: team!, size: 22),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              team!.name.split(' ').first,
              style: AppText.caption.copyWith(
                  color: isWinner
                      ? AppColors.textPrimary
                      : AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            )),
            if (isWinner)
              const Icon(Icons.emoji_events_rounded,
                  size: 12, color: AppColors.gold),
          ] else
            Text(label ?? 'TBD',
                style: AppText.caption.copyWith(color: AppColors.textMuted)),
        ]),
      );
}

// ─── Standings Tab ────────────────────────────────────────────────────────────
class _StandingsTab extends StatelessWidget {
  final TournamentModel tournament;
  const _StandingsTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (tournament.standings.isEmpty) {
      return const EmptyState(
          icon: Icons.leaderboard_rounded,
          title: 'No Standings Yet',
          subtitle: 'Standings will appear once matches begin');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: const Border(
              top: BorderSide(color: AppColors.border),
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 32),
            const Expanded(
                child: Text('TEAM',
                    style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5))),
            for (final label in ['P', 'W', 'L', 'PTS'])
              SizedBox(
                width: label == 'PTS' ? 44 : 30,
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: label == 'PTS'
                            ? AppColors.cyan
                            : AppColors.textMuted,
                        letterSpacing: 1.5),
                    textAlign: TextAlign.center),
              ),
          ]),
        ),
        // Rows
        ...tournament.standings.asMap().entries.map((e) {
          final s = e.value;
          final rank = e.key + 1;
          final isTop3 = rank <= 3;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isTop3 ? AppColors.cyan.withOpacity(0.03) : AppColors.bg1,
              border: const Border(
                left: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(children: [
              SizedBox(width: 32, child: _RankWidget(rank: rank)),
              Expanded(
                  child: Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      s.teamName.length >= 2
                          ? s.teamName.substring(0, 2)
                          : s.teamName,
                      style: AppText.label.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(s.teamName,
                        style: AppText.bodyMd.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis)),
              ])),
              SizedBox(
                  width: 30,
                  child: Text('${s.played}',
                      style: AppText.body, textAlign: TextAlign.center)),
              SizedBox(
                  width: 30,
                  child: Text('${s.wins}',
                      style: AppText.body.copyWith(color: AppColors.green),
                      textAlign: TextAlign.center)),
              SizedBox(
                  width: 30,
                  child: Text('${s.losses}',
                      style: AppText.body.copyWith(color: AppColors.red),
                      textAlign: TextAlign.center)),
              SizedBox(
                  width: 44,
                  child: Text('${s.points}',
                      style: AppText.heading
                          .copyWith(color: AppColors.cyan, fontSize: 16),
                      textAlign: TextAlign.center)),
            ]),
          );
        }),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _RankWidget extends StatelessWidget {
  final int rank;
  const _RankWidget({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 18));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 18));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 18));
    return Text('$rank',
        style: AppText.body.copyWith(color: AppColors.textMuted));
  }
}

// ─── Registration Screen ──────────────────────────────────────────────────────
class _RegisterTeamScreen extends StatefulWidget {
  final TournamentModel tournament;
  const _RegisterTeamScreen({required this.tournament});

  @override
  State<_RegisterTeamScreen> createState() => _RegisterTeamScreenState();
}

class _RegisterTeamScreenState extends State<_RegisterTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  int _currentStep = 0;

  final _teamNameCtrl = TextEditingController();
  final _teamTagCtrl = TextEditingController();
  final _founderNameCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _coachNameCtrl = TextEditingController();
  final _asstCoachNameCtrl = TextEditingController();

  static const _steps = [
    'TEAM IDENTITY',
    'MANAGEMENT',
    'COACHING STAFF',
    'PLAYER ROSTER',
  ];

  @override
  void dispose() {
    _teamNameCtrl.dispose();
    _teamTagCtrl.dispose();
    _founderNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _coachNameCtrl.dispose();
    _asstCoachNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted)
      return _SuccessScreen(
          tournament: widget.tournament,
          teamName: _teamNameCtrl.text,
          teamTag: _teamTagCtrl.text);

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 15, color: AppColors.textSecondary),
          ),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('REGISTER TEAM',
              style: AppText.heading.copyWith(fontSize: 16, letterSpacing: 2)),
          Text(widget.tournament.title,
              style: AppText.caption.copyWith(color: AppColors.cyan),
              overflow: TextOverflow.ellipsis),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StepProgress(
            totalSteps: _steps.length,
            currentStep: _currentStep,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          // Step indicator
          _StepHeader(
            steps: _steps,
            currentStep: _currentStep,
            onStepTap: (i) {
              if (i <= _currentStep) setState(() => _currentStep = i);
            },
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(_currentStep),
              ),
            ),
          ),
          // Navigation
          _FormNavigation(
            currentStep: _currentStep,
            totalSteps: _steps.length,
            onBack: () => setState(() => _currentStep--),
            onNext: () {
              if (_currentStep < _steps.length - 1) {
                setState(() => _currentStep++);
              } else {
                if (_formKey.currentState!.validate()) {
                  HapticFeedback.vibrate();
                  setState(() => _submitted = true);
                } else {
                  HapticFeedback.heavyImpact();
                }
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    return switch (step) {
      0 => _Step1TeamIdentity(
          key: const ValueKey(0),
          teamNameCtrl: _teamNameCtrl,
          teamTagCtrl: _teamTagCtrl,
          onUpload: () => _showUploadSnack(),
        ),
      1 => _Step2Management(
          key: const ValueKey(1),
          founderNameCtrl: _founderNameCtrl,
          contactEmailCtrl: _contactEmailCtrl,
          contactPhoneCtrl: _contactPhoneCtrl,
          onUpload: () => _showUploadSnack(),
        ),
      2 => _Step3Coaching(
          key: const ValueKey(2),
          coachNameCtrl: _coachNameCtrl,
          asstCoachNameCtrl: _asstCoachNameCtrl,
          onUpload: () => _showUploadSnack(),
        ),
      _ => _Step4Roster(
          key: const ValueKey(3),
          onUpload: () => _showUploadSnack(),
        ),
    };
  }

  void _showUploadSnack() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image picker not connected in demo'),
        backgroundColor: AppColors.bg2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

// ─── Step Progress Bar ────────────────────────────────────────────────────────
class _StepProgress extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const _StepProgress({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final width = constraints.maxWidth;
      final progress = (currentStep + 1) / totalSteps;
      return Stack(children: [
        Container(height: 3, color: AppColors.bg3),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 3,
          width: width * progress,
          color: AppColors.cyan,
        ),
      ]);
    });
  }
}

// ─── Step Header ─────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final ValueChanged<int> onStepTap;
  const _StepHeader(
      {required this.steps,
      required this.currentStep,
      required this.onStepTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final idx = e.key;
          final label = e.value;
          final isDone = idx < currentStep;
          final isActive = idx == currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTap(idx),
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.cyan
                        : isActive
                            ? AppColors.bg0
                            : AppColors.bg3,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.cyan
                          : isActive
                              ? AppColors.cyan
                              : AppColors.border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 12, color: AppColors.bg0)
                        : Text('${idx + 1}',
                            style: AppText.label.copyWith(
                                fontSize: 10,
                                color: isActive
                                    ? AppColors.cyan
                                    : AppColors.textMuted)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label.split(' ').first,
                  style: AppText.label.copyWith(
                      fontSize: 8,
                      letterSpacing: 0.5,
                      color: isActive ? AppColors.cyan : AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Form Navigation ──────────────────────────────────────────────────────────
class _FormNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _FormNavigation(
      {required this.currentStep,
      required this.totalSteps,
      required this.onBack,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        if (currentStep > 0)
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.arrow_back_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('BACK',
                      style: AppText.btnSm
                          .copyWith(color: AppColors.textSecondary)),
                ]),
              ),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onNext,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(isLast ? 'SUBMIT ROSTER' : 'CONTINUE',
                    style: AppText.btnSm
                        .copyWith(color: AppColors.bg0, letterSpacing: 1.5)),
                const SizedBox(width: 6),
                Icon(
                  isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.bg0,
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Step 1: Team Identity ────────────────────────────────────────────────────
class _Step1TeamIdentity extends StatelessWidget {
  final TextEditingController teamNameCtrl;
  final TextEditingController teamTagCtrl;
  final VoidCallback onUpload;

  const _Step1TeamIdentity({
    super.key,
    required this.teamNameCtrl,
    required this.teamTagCtrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _UploadCircle(size: 96, label: 'TEAM LOGO', onTap: onUpload),
          ),
          const SizedBox(height: 28),
          _FormField(
            label: 'TEAM NAME',
            controller: teamNameCtrl,
            hint: 'Full official team name',
            icon: Icons.groups_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'TEAM TAG',
            hint: 'e.g. T1, NAVI, SEN',
            controller: teamTagCtrl,
            icon: Icons.tag_rounded,
            isRequired: true,
            maxLength: 5,
            allCaps: true,
          ),
        ],
      );
}

// ─── Step 2: Management ───────────────────────────────────────────────────────
class _Step2Management extends StatelessWidget {
  final TextEditingController founderNameCtrl;
  final TextEditingController contactEmailCtrl;
  final TextEditingController contactPhoneCtrl;
  final VoidCallback onUpload;

  const _Step2Management({
    super.key,
    required this.founderNameCtrl,
    required this.contactEmailCtrl,
    required this.contactPhoneCtrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'FOUNDER / OWNER NAME',
            hint: 'Legal full name',
            controller: founderNameCtrl,
            icon: Icons.person_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'CONTACT EMAIL',
            hint: 'manager@team.gg',
            controller: contactEmailCtrl,
            icon: Icons.email_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'PHONE / DISCORD',
            hint: '+1 234 567 8900 or User#0000',
            controller: contactPhoneCtrl,
            icon: Icons.phone_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 24),
          _UploadRect(label: 'MANAGER ID / PASSPORT', onTap: onUpload),
        ],
      );
}

// ─── Step 3: Coaching Staff ───────────────────────────────────────────────────
class _Step3Coaching extends StatelessWidget {
  final TextEditingController coachNameCtrl;
  final TextEditingController asstCoachNameCtrl;
  final VoidCallback onUpload;

  const _Step3Coaching({
    super.key,
    required this.coachNameCtrl,
    required this.asstCoachNameCtrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PersonCard(
            title: 'HEAD COACH',
            controller: coachNameCtrl,
            onUpload: onUpload,
          ),
          const SizedBox(height: 20),
          _PersonCard(
            title: 'ASSISTANT COACH',
            controller: asstCoachNameCtrl,
            onUpload: onUpload,
          ),
        ],
      );
}

// ─── Step 4: Player Roster (Dynamic & Flexible) ───────────────────────────────
class _Step4Roster extends StatefulWidget {
  final VoidCallback onUpload;

  const _Step4Roster({super.key, required this.onUpload});

  @override
  State<_Step4Roster> createState() => _Step4RosterState();
}

class _Step4RosterState extends State<_Step4Roster> {
  // Local state management tracking list of active player/sub entries dynamically
  final List<_DynamicPlayerItem> _roster = [];

  @override
  void initState() {
    super.initState();
    // Start with 1 default entry (Captain) to prompt the user immediately
    _addNewPlayer(isFirst: true);
  }

  void _addNewPlayer({bool isFirst = false}) {
    setState(() {
      _roster.add(
        _DynamicPlayerItem(
          fullNameCtrl: TextEditingController(),
          ignCtrl: TextEditingController(),
          uidCtrl: TextEditingController(),
          nationalityCtrl: TextEditingController(),
          dobCtrl: TextEditingController(),
          roleCtrl: TextEditingController(),
          isSub: false,
          isCaptain: isFirst,
        ),
      );
    });
  }

  void _removePlayer(int index) {
    setState(() {
      _roster.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var player in _roster) {
      player.fullNameCtrl.dispose();
      player.ignCtrl.dispose();
      player.uidCtrl.dispose();
      player.nationalityCtrl.dispose();
      player.dobCtrl.dispose();
      player.roleCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rules Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All active players and substitutes must provide details matching their official National ID or Passport.',
                  style: AppText.caption.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Roster Dynamic List Builder
        if (_roster.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No players added yet. Tap below to begin.',
              style: AppText.body.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roster.length,
            itemBuilder: (context, index) {
              return _PlayerEntryForm(
                index: index,
                item: _roster[index],
                onRemove: () => _removePlayer(index),
                onUpload: widget.onUpload,
                onTogglePosition: (isSubValue) {
                  setState(() {
                    _roster[index].isSub = isSubValue;
                    if (isSubValue) _roster[index].isCaptain = false;
                  });
                },
                onToggleCaptain: (isCaptainValue) {
                  setState(() {
                    // Reset all other captains if this one becomes captain
                    if (isCaptainValue) {
                      for (var p in _roster) {
                        p.isCaptain = false;
                      }
                      _roster[index].isSub = false;
                    }
                    _roster[index].isCaptain = isCaptainValue;
                  });
                },
              );
            },
          ),
        const SizedBox(height: 12),

        // ADD NEW PLAYER BUTTON
        GestureDetector(
          onTap: () => _addNewPlayer(),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_rounded,
                    color: AppColors.cyan, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ADD NEW PLAYER / SUBSTITUTE',
                  style: AppText.btnSm
                      .copyWith(color: AppColors.cyan, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper Object model to track controllers locally in Step 4
class _DynamicPlayerItem {
  final TextEditingController fullNameCtrl;
  final TextEditingController ignCtrl;
  final TextEditingController uidCtrl;
  final TextEditingController nationalityCtrl;
  final TextEditingController dobCtrl;
  final TextEditingController roleCtrl;
  bool isSub;
  bool isCaptain;

  _DynamicPlayerItem({
    required this.fullNameCtrl,
    required this.ignCtrl,
    required this.uidCtrl,
    required this.nationalityCtrl,
    required this.dobCtrl,
    required this.roleCtrl,
    required this.isSub,
    required this.isCaptain,
  });
}

// ─── Shared/Internal form sub-components ───────────────────────────────────────
class _PersonCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onUpload;

  const _PersonCard({
    required this.title,
    required this.controller,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppText.label.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'FULL NAME',
              hint: 'Legal full name',
              controller: controller,
              icon: Icons.person_outline_rounded,
              isRequired: false,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'NICKNAME / ALIAS',
              hint: 'e.g. kkOma',
              icon: Icons.gamepad_rounded,
              isRequired: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'NATIONALITY',
                    hint: 'e.g. KR',
                    icon: Icons.flag_rounded,
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'DATE OF BIRTH',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_rounded,
                    isRequired: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _UploadRect(label: 'UPLOAD $title ID', onTap: onUpload),
          ],
        ),
      );
}

class _PlayerEntryForm extends StatelessWidget {
  final int index;
  final _DynamicPlayerItem item;
  final VoidCallback onRemove;
  final VoidCallback onUpload;
  final ValueChanged<bool> onTogglePosition;
  final ValueChanged<bool> onToggleCaptain;

  const _PlayerEntryForm({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onUpload,
    required this.onTogglePosition,
    required this.onToggleCaptain,
  });

  @override
  Widget build(BuildContext context) {
    String positionLabel = item.isSub ? 'SUBSTITUTE' : 'MAIN ROSTER';
    if (item.isCaptain) positionLabel += '  ·  CAPTAIN';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isCaptain
              ? AppColors.cyan.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (item.isCaptain)
                    const Icon(Icons.military_tech_rounded,
                        size: 16, color: AppColors.purple),
                  if (item.isCaptain) const SizedBox(width: 5),
                  Text(
                    'MEMBER #${index + 1} ($positionLabel)',
                    style: AppText.label.copyWith(
                      color: item.isCaptain
                          ? AppColors.cyan
                          : AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.red, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Full Name
          _ThemedInput(
              hint: 'Legal Full Name',
              icon: Icons.badge_rounded,
              controller: item.fullNameCtrl),
          const SizedBox(height: 12),

          // IGN & Game UID (Side by Side)
          Row(
            children: [
              Expanded(
                child: _ThemedInput(
                    hint: 'In-Game Name (IGN)',
                    icon: Icons.gamepad_rounded,
                    controller: item.ignCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemedInput(
                    hint: 'Game UID',
                    icon: Icons.tag_rounded,
                    controller: item.uidCtrl),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nationality & DOB (Side by Side)
          Row(
            children: [
              Expanded(
                child: _ThemedInput(
                    hint: 'Nationality',
                    icon: Icons.flag_rounded,
                    controller: item.nationalityCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemedInput(
                    hint: 'DOB (YYYY-MM-DD)',
                    icon: Icons.calendar_today_rounded,
                    controller: item.dobCtrl),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // In-Game Role
          _ThemedInput(
              hint: 'In-Game Role (e.g. Support, IGL, Duelist)',
              icon: Icons.sports_esports_rounded,
              controller: item.roleCtrl),
          const SizedBox(height: 14),

          // Toggles Tiers Controls
          Row(
            children: [
              // Position Toggle (Main vs Sub)
              Text('Substitute:',
                  style:
                      AppText.caption.copyWith(color: AppColors.textSecondary)),
              Switch.adaptive(
                value: item.isSub,
                activeColor: AppColors.cyan,
                onChanged: onTogglePosition,
              ),
              const Spacer(),
              // Captain Toggle
              Text('Team Captain:',
                  style:
                      AppText.caption.copyWith(color: AppColors.textSecondary)),
              Switch.adaptive(
                value: item.isCaptain,
                activeColor: AppColors.purple,
                onChanged: onToggleCaptain,
              ),
            ],
          ),
          const SizedBox(height: 12),

          _UploadRect(label: 'PLAYER ID / PASSPORT', onTap: onUpload),
        ],
      ),
    );
  }
}

class _ThemedInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  const _ThemedInput(
      {required this.hint, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 16),
        filled: true,
        fillColor: AppColors.bg3,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData icon;
  final bool isRequired;
  final int? maxLength;
  final bool allCaps;

  const _FormField({
    required this.label,
    required this.hint,
    this.controller,
    required this.icon,
    required this.isRequired,
    this.maxLength,
    this.allCaps = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style:
                      AppText.label.copyWith(fontSize: 11, letterSpacing: 1.2)),
              if (!isRequired)
                Text('  optional',
                    style: AppText.caption
                        .copyWith(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller ?? TextEditingController(),
            style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
            maxLength: maxLength,
            textCapitalization: allCaps
                ? TextCapitalization.characters
                : TextCapitalization.words,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 16),
              filled: true,
              fillColor: AppColors.bg3,
              isDense: true,
              counterStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 10),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: isRequired
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null,
          ),
        ],
      );
}

class _UploadCircle extends StatelessWidget {
  final double size;
  final String label;
  final VoidCallback onTap;

  const _UploadCircle(
      {required this.size, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: AppColors.bg3,
                shape: BoxShape.circle,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      color: AppColors.textSecondary, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.label.copyWith(
                fontSize: 10, letterSpacing: 1, color: AppColors.textSecondary),
          ),
        ],
      );
}

class _UploadRect extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _UploadRect({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.label.copyWith(fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file_rounded,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text('Tap to upload',
                      style: AppText.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─── Success Screen ───────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  final TournamentModel tournament;
  final String teamName;
  final String teamTag;

  const _SuccessScreen({
    required this.tournament,
    required this.teamName,
    required this.teamTag,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg0,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.cyan.withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.cyan, size: 36),
                ),
                const SizedBox(height: 28),
                Text(
                  'ROSTER SUBMITTED',
                  style: AppText.displaySm
                      .copyWith(letterSpacing: 2, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (teamName.isNotEmpty)
                  Text(
                    '$teamName${teamTag.isNotEmpty ? ' [${teamTag.toUpperCase()}]' : ''}',
                    style: AppText.heading
                        .copyWith(color: AppColors.cyan, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Text(
                  tournament.title,
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded,
                          size: 16, color: AppColors.purple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your roster is pending review by the tournament organizers.',
                          style: AppText.caption.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'BACK TO TOURNAMENT',
                        style: AppText.btnSm.copyWith(
                            color: AppColors.textPrimary, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
