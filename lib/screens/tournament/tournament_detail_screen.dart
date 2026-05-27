import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common/widgets.dart';
import '../team/team_detail_screen.dart';

// ─── Icon constants — thin outlined style ─────────────────────────────────────
class AppIcons {
  // Use outlined variants everywhere for a flat, non-AI aesthetic
  static const trophy = Icons.emoji_events_outlined;
  static const team = Icons.group_outlined;
  static const format = Icons.account_tree_outlined;
  static const calendar = Icons.calendar_today_outlined;
  static const calendarEnd = Icons.event_outlined;
  static const clock = Icons.schedule_outlined;
  static const location = Icons.place_outlined;
  static const org = Icons.corporate_fare_outlined;
  static const info = Icons.info_outlined;
  static const list = Icons.format_list_bulleted_outlined;
  static const flag = Icons.flag_outlined;
  static const person = Icons.person_outline;
  static const chevronRight = Icons.chevron_right;
  static const back = Icons.arrow_back_ios;
  static const share = Icons.ios_share_outlined;
  static const leaderboard = Icons.bar_chart_outlined;
  static const star = Icons.star_outline;
  static const add = Icons.add_circle_outline;
  static const check = Icons.check_circle_outline;
  static const live = Icons.radio_button_checked_outlined;
  static const tag = Icons.label_outline;
  static const upload = Icons.upload_outlined;
  static const photo = Icons.photo_camera_outlined;
  static const delete = Icons.delete_outline;
  static const email = Icons.mail_outline;
  static const phone = Icons.phone_outlined;
  static const badge = Icons.badge_outlined;
  static const gamepad = Icons.sports_esports_outlined;
  static const send = Icons.send_outlined;
  static const hourglass = Icons.hourglass_empty_outlined;
  static const question = Icons.help_outline;
  static const medal = Icons.military_tech_outlined;
  static const arrowFwd = Icons.arrow_forward;
  static const personAdd = Icons.person_add_alt_1_outlined;
}

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
    'STANDINGS',
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
            expandedHeight: 240,
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
                  child: const Icon(AppIcons.back,
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
                  child: const Icon(AppIcons.share,
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
              preferredSize: const Size.fromHeight(48),
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
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
          right: -16,
          bottom: 40,
          child: Opacity(
            opacity: 0.06,
            child: Text(t.game.emoji, style: const TextStyle(fontSize: 160)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 72, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
              Text(t.title,
                  style: AppText.displayMd
                      .copyWith(letterSpacing: 0.3, height: 1.15)),
              const SizedBox(height: 4),
              if (t.organizer != null)
                Text('Organized by ${t.organizer}',
                    style: AppText.body
                        .copyWith(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _StatPill(
                    icon: AppIcons.trophy,
                    value: t.prizePoolDisplay,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: AppIcons.team,
                    value: '${t.registeredTeams}/${t.maxTeams} teams',
                    color: AppColors.cyan,
                  ),
                  if (t.location != null) ...[
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: AppIcons.location,
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
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.35)),
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
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
      ..color = AppColors.cyan.withValues(alpha: 0.03)
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

// ─── Shared Section Label ────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _SectionLabel({required this.text, this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.cyan),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(text,
              style: AppText.label.copyWith(
                  fontSize: 10,
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
        Row(children: [
          Expanded(
              child: _MiniStatCard(
                  label: 'PRIZE POOL',
                  value: t.prizePoolDisplay,
                  valueColor: AppColors.gold,
                  icon: AppIcons.trophy)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStatCard(
                  label: 'TEAMS',
                  value: '${t.registeredTeams}/${t.maxTeams}',
                  icon: AppIcons.team)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStatCard(
                  label: 'FORMAT',
                  value: _formatShort(t.format),
                  icon: AppIcons.format)),
        ]),
        const SizedBox(height: 28),
        _SectionLabel(text: 'ABOUT THIS TOURNAMENT', icon: AppIcons.info),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor(),
          child: Text(t.description ?? 'No description available.',
              style: AppText.body.copyWith(height: 1.7)),
        ),
        const SizedBox(height: 28),
        _SectionLabel(text: 'DETAILS', icon: AppIcons.list),
        Container(
          decoration: _cardDecor(),
          child: Column(children: [
            _DetailRow(
                icon: AppIcons.calendar,
                label: 'Start',
                value: t.startDateDisplay),
            _DetailRow(
                icon: AppIcons.calendarEnd,
                label: 'End',
                value: t.endDateDisplay),
            _DetailRow(
                icon: AppIcons.clock,
                label: 'Reg. Deadline',
                value: t.registrationDeadlineDisplay),
            _DetailRow(
                icon: AppIcons.location,
                label: 'Location',
                value: t.location ?? 'TBA'),
            _DetailRow(
                icon: AppIcons.format,
                label: 'Format',
                value: _formatLabel(t.format)),
            _DetailRow(
                icon: AppIcons.org,
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
            icon: AppIcons.add,
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

  BoxDecoration _cardDecor({Color? accentColor}) => BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor ?? AppColors.border),
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
          icon: AppIcons.team,
          title: 'No Teams Yet',
          subtitle: 'Be the first to register your team');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: tournament.teams.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(AppIcons.team, size: 13, color: AppColors.cyan),
                  const SizedBox(width: 6),
                  Text(
                    '${tournament.teams.length} REGISTERED',
                    style: AppText.label.copyWith(
                        color: AppColors.cyan, fontSize: 10, letterSpacing: 1),
                  ),
                ]),
              ),
            ]),
          );
        }
        final team = tournament.teams[i - 1];
        return _TeamCard(
          team: team,
          rank: i,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => TeamDetailScreen(team: team))),
        );
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamModel team;
  final int rank;
  final VoidCallback onTap;
  const _TeamCard(
      {required this.team, required this.rank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (team.status) {
      TeamStatus.approved => AppColors.green,
      TeamStatus.pending => AppColors.gold,
      _ => AppColors.red,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text('$rank',
                      style: AppText.label
                          .copyWith(color: AppColors.textMuted, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              TeamAvatar(team: team, size: 44),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(team.name,
                        style: AppText.heading.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(AppIcons.flag,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(team.country ?? 'Unknown',
                          style: AppText.caption
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      const Icon(AppIcons.person,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text('${team.players.length} members',
                          style: AppText.caption),
                    ]),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  Text('${team.wins}W',
                      style: AppText.caption.copyWith(
                          color: AppColors.green, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Text('${team.losses}L',
                      style: AppText.caption.copyWith(
                          color: AppColors.red, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                const Icon(AppIcons.chevronRight,
                    color: AppColors.textMuted, size: 16),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bg0.withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  team.status.name.toUpperCase(),
                  style:
                      AppText.label.copyWith(color: statusColor, fontSize: 9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${team.players.length} player${team.players.length == 1 ? '' : 's'} registered',
                  style: AppText.caption
                      .copyWith(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              // View-only indicator
              Row(children: [
                const Icon(Icons.visibility_outlined,
                    size: 11, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('View',
                    style: AppText.caption
                        .copyWith(color: AppColors.textMuted, fontSize: 10)),
              ]),
            ]),
          ),
        ]),
      ),
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
          icon: AppIcons.clock,
          title: 'No Matches Yet',
          subtitle: 'Schedule will be posted soon');
    }

    final grouped = <String, List<MatchModel>>{};
    for (final m in tournament.matches) {
      (grouped[m.round] ??= []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: grouped.entries
          .map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cyan.withValues(alpha: 0.15),
                          AppColors.cyan.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(AppIcons.flag,
                          size: 12, color: AppColors.cyan),
                      const SizedBox(width: 6),
                      Text(e.key.toUpperCase(),
                          style: AppText.label.copyWith(
                              color: AppColors.cyan,
                              fontSize: 10,
                              letterSpacing: 1.2)),
                    ]),
                  ),
                  ...e.value.map((m) =>
                      _ScheduleMatchCard(match: m, tournament: tournament)),
                  const SizedBox(height: 8),
                ],
              ))
          .toList(),
    );
  }
}

class _ScheduleMatchCard extends StatelessWidget {
  final MatchModel match;
  final TournamentModel tournament;
  const _ScheduleMatchCard({required this.match, required this.tournament});

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isLive ? AppColors.red.withValues(alpha: 0.5) : AppColors.border,
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            const Icon(AppIcons.clock, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(match.scheduledAt ?? 'TBA', style: AppText.caption),
            const Spacer(),
            _MatchStatusChip(status: match.status),
          ]),
        ),
        Container(height: 0.5, color: AppColors.border),
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
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3)),
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
                  child: Icon(AppIcons.question,
                      size: 14, color: AppColors.textMuted)),
            ),
            const SizedBox(height: 6),
            Text('TBD',
                style: AppText.caption.copyWith(color: AppColors.textMuted)),
          ],
        ],
      );
}

class _MatchStatusChip extends StatelessWidget {
  final String status;
  const _MatchStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      'live' => (AppColors.cyan, 'LIVE', AppIcons.live),
      'completed' => (AppColors.green, 'DONE', AppIcons.check),
      _ => (AppColors.textMuted, 'UPCOMING', AppIcons.clock),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppText.label.copyWith(color: color, fontSize: 9)),
      ]),
    );
  }
}

// ─── Bracket Tab ──────────────────────────────────────────────────────────────
class _BracketTab extends StatelessWidget {
  final TournamentModel tournament;
  const _BracketTab({required this.tournament});

  static const _rounds = [
    'Group Stage - Week 1',
    'Group Stage - Week 2',
    'Semi Final',
    'Grand Final',
  ];

  TeamModel? _findTeam(String? id) =>
      id == null ? null : tournament.teams.where((t) => t.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    if (tournament.matches.isEmpty) {
      return const EmptyState(
          icon: AppIcons.format,
          title: 'Bracket Not Available',
          subtitle: 'The bracket will be generated after registration closes');
    }

    // Build list of round sections
    final roundSections = _rounds.map((round) {
      final matches = tournament.matches
          .where((m) =>
              m.round.startsWith(round.split(' - ').first) || m.round == round)
          .toList();
      return (round: round, matches: matches);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      itemCount: roundSections.length,
      itemBuilder: (context, roundIndex) {
        final section = roundSections[roundIndex];
        final matches = section.matches;

        // Build pairs for 2-column grid
        final rows = <List<MatchModel?>>[];
        if (matches.isEmpty) {
          rows.add([null, null]); // dummy row
        } else {
          for (int i = 0; i < matches.length; i += 2) {
            rows.add([
              matches[i],
              i + 1 < matches.length ? matches[i + 1] : null,
            ]);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.purple.withValues(alpha: 0.2),
                    AppColors.cyan.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
              ),
              child: Row(children: [
                const Icon(AppIcons.format, size: 13, color: AppColors.cyan),
                const SizedBox(width: 8),
                Text(section.round,
                    style: AppText.label.copyWith(
                        color: AppColors.cyan, fontSize: 10, letterSpacing: 1)),
              ]),
            ),

            // 2-column match grid — vertical only
            ...rows.map((pair) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left card
                      Expanded(
                        child: pair[0] == null
                            ? _BracketMatchCard(
                                match: null,
                                team1: null,
                                team2: null,
                                isDummy: matches.isEmpty,
                              )
                            : _BracketMatchCard(
                                match: pair[0],
                                team1: _findTeam(pair[0]!.team1Id),
                                team2: _findTeam(pair[0]!.team2Id),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // Right card (or empty space)
                      Expanded(
                        child: pair[1] == null
                            ? const SizedBox.shrink()
                            : _BracketMatchCard(
                                match: pair[1],
                                team1: _findTeam(pair[1]!.team1Id),
                                team2: _findTeam(pair[1]!.team2Id),
                              ),
                      ),
                    ],
                  ),
                )),

            // Space between rounds
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _BracketMatchCard extends StatelessWidget {
  final MatchModel? match;
  final TeamModel? team1;
  final TeamModel? team2;
  final bool isDummy;
  const _BracketMatchCard(
      {required this.match,
      required this.team1,
      required this.team2,
      this.isDummy = false});

  @override
  Widget build(BuildContext context) {
    final isDone = match?.status == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: isDone ? AppColors.green.withValues(alpha: 0.04) : AppColors.bg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(children: [
        if (match?.scheduledAt != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              const Icon(AppIcons.clock, size: 10, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(match!.scheduledAt!,
                  style: AppText.caption.copyWith(fontSize: 9)),
            ]),
          ),
        _BracketSlotRow(
          teamName: isDummy ? 'TBD' : (team1?.name ?? 'TBD'),
          score: match?.score1 ?? 0,
          isWinner:
              match != null && match!.winnerId == match!.team1Id && isDone,
          team: team1,
        ),
        Container(height: 0.5, color: AppColors.border),
        _BracketSlotRow(
          teamName: isDummy ? 'TBD' : (team2?.name ?? 'TBD'),
          score: match?.score2 ?? 0,
          isWinner:
              match != null && match!.winnerId == match!.team2Id && isDone,
          team: team2,
        ),
      ]),
    );
  }
}

class _BracketSlotRow extends StatelessWidget {
  final String teamName;
  final int score;
  final bool isWinner;
  final TeamModel? team;
  const _BracketSlotRow(
      {required this.teamName,
      required this.score,
      required this.isWinner,
      this.team});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isWinner
              ? AppColors.cyan.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Row(children: [
          if (team != null) ...[
            TeamAvatar(team: team!, size: 22),
            const SizedBox(width: 7),
          ],
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(AppIcons.trophy, size: 11, color: AppColors.gold),
            ),
          Expanded(
            child: Text(
              teamName.split(' ').first,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                color:
                    isWinner ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isWinner ? AppColors.green : AppColors.textMuted,
            ),
          ),
        ]),
      );
}

// ─── Standings Tab ────────────────────────────────────────────────────────────
// Improved: cleaner podium, better table with alternating rows, rank highlight
class _StandingsTab extends StatelessWidget {
  final TournamentModel tournament;
  const _StandingsTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (tournament.standings.isEmpty) {
      return const EmptyState(
          icon: AppIcons.leaderboard,
          title: 'No Standings Yet',
          subtitle: 'Standings will appear once matches begin');
    }

    final sorted = List.from(tournament.standings)
      ..sort((a, b) => (b.points as int).compareTo(a.points as int));

    final top3 = sorted.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Podium ─────────────────────────────────
        if (top3.isNotEmpty) ...[
          _SectionLabel(text: 'TOP PERFORMERS', icon: AppIcons.trophy),
          _ImprovedPodiumRow(top3: top3),
          const SizedBox(height: 28),
        ],

        // ── Table header ───────────────────────────
        _SectionLabel(text: 'FULL STANDINGS', icon: AppIcons.leaderboard),

        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            const SizedBox(width: 36),
            const Expanded(
                child: Text('TEAM',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5))),
            for (final col in [
              ('P', false),
              ('W', false),
              ('L', false),
              ('PTS', true),
            ])
              SizedBox(
                width: col.$2 ? 48 : 32,
                child: Text(col.$1,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: col.$2 ? AppColors.cyan : AppColors.textMuted,
                        letterSpacing: 1.5),
                    textAlign: TextAlign.center),
              ),
          ]),
        ),

        // Rows
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: sorted.asMap().entries.map((e) {
                final rank = e.key + 1;
                final s = e.value;
                final isTop1 = rank == 1;
                final isTop3 = rank <= 3;
                final isEven = e.key % 2 == 0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isTop1
                        ? AppColors.gold.withValues(alpha: 0.04)
                        : isTop3
                            ? AppColors.cyan.withValues(alpha: 0.03)
                            : isEven
                                ? AppColors.bg1
                                : AppColors.bg0,
                    border: e.key < sorted.length - 1
                        ? const Border(
                            bottom:
                                BorderSide(color: AppColors.border, width: 0.5))
                        : null,
                  ),
                  child: Row(children: [
                    // Rank
                    SizedBox(
                      width: 36,
                      child: _ImprovedRankBadge(rank: rank),
                    ),
                    // Team
                    Expanded(
                        child: Row(children: [
                      // Initials badge
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isTop1
                              ? AppColors.gold.withValues(alpha: 0.12)
                              : AppColors.bg3,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isTop1
                                  ? AppColors.gold.withValues(alpha: 0.3)
                                  : AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            s.teamName.length >= 2
                                ? s.teamName.substring(0, 2)
                                : s.teamName,
                            style: AppText.label.copyWith(
                                color: isTop1 ? AppColors.gold : AppColors.cyan,
                                fontWeight: FontWeight.w700,
                                fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(s.teamName,
                              style: AppText.bodyMd.copyWith(
                                  fontSize: 13,
                                  fontWeight: isTop1
                                      ? FontWeight.w700
                                      : FontWeight.w500),
                              overflow: TextOverflow.ellipsis)),
                    ])),
                    // P
                    SizedBox(
                        width: 32,
                        child: Text('${s.played}',
                            style: AppText.body
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center)),
                    // W
                    SizedBox(
                        width: 32,
                        child: Text('${s.wins}',
                            style: AppText.body.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center)),
                    // L
                    SizedBox(
                        width: 32,
                        child: Text('${s.losses}',
                            style: AppText.body.copyWith(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center)),
                    // PTS
                    SizedBox(
                      width: 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isTop1
                              ? AppColors.gold.withValues(alpha: 0.12)
                              : AppColors.cyan.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${s.points}',
                            style: AppText.heading.copyWith(
                                color: isTop1 ? AppColors.gold : AppColors.cyan,
                                fontSize: 14),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ─── Improved Podium ──────────────────────────────────────────────────────────
class _ImprovedPodiumRow extends StatelessWidget {
  final List top3;
  const _ImprovedPodiumRow({required this.top3});

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        // Podium visual
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd
            if (second != null)
              Expanded(
                  child: _PodiumPillar(
                entry: second,
                rank: 2,
                pillarHeight: 56,
                accentColor: const Color(0xFFC0C0C0),
              ))
            else
              const Expanded(child: SizedBox()),
            const SizedBox(width: 6),
            // 1st — centre, tallest
            Expanded(
                child: _PodiumPillar(
              entry: first,
              rank: 1,
              pillarHeight: 80,
              accentColor: AppColors.gold,
            )),
            const SizedBox(width: 6),
            // 3rd
            if (third != null)
              Expanded(
                  child: _PodiumPillar(
                entry: third,
                rank: 3,
                pillarHeight: 44,
                accentColor: const Color(0xFFCD7F32),
              ))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 12),
        // Podium base bar
        Row(children: [
          if (second != null) Expanded(child: _PodiumBase(rank: 2)),
          const SizedBox(width: 6),
          Expanded(child: _PodiumBase(rank: 1)),
          const SizedBox(width: 6),
          if (third != null) Expanded(child: _PodiumBase(rank: 3)),
          if (third == null) const Expanded(child: SizedBox()),
        ]),
      ]),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  final dynamic entry;
  final int rank;
  final double pillarHeight;
  final Color accentColor;
  const _PodiumPillar({
    required this.entry,
    required this.rank,
    required this.pillarHeight,
    required this.accentColor,
  });

  String get _medal => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        _ => '🥉',
      };

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(_medal, style: TextStyle(fontSize: rank == 1 ? 26.0 : 20.0)),
          const SizedBox(height: 6),
          Text(
            entry.teamName.split(' ').first,
            style: AppText.label.copyWith(
                color: accentColor, fontWeight: FontWeight.w700, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.points} PTS',
              style: AppText.label.copyWith(
                  color: accentColor, fontSize: 9, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          // Pillar
          Container(
            height: pillarHeight,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(
                top: BorderSide(color: accentColor.withValues(alpha: 0.3)),
                left: BorderSide(color: accentColor.withValues(alpha: 0.2)),
                right: BorderSide(color: accentColor.withValues(alpha: 0.2)),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                    color: accentColor.withValues(alpha: 0.4),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      );
}

class _PodiumBase extends StatelessWidget {
  final int rank;
  const _PodiumBase({required this.rank});

  Color get _color => switch (rank) {
        1 => AppColors.gold,
        2 => const Color(0xFFC0C0C0),
        _ => const Color(0xFFCD7F32),
      };

  @override
  Widget build(BuildContext context) => Container(
        height: 6,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: _color.withValues(alpha: 0.4)),
        ),
      );
}

class _ImprovedRankBadge extends StatelessWidget {
  final int rank;
  const _ImprovedRankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 18));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 18));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 18));
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text('$rank',
            style: AppText.label
                .copyWith(color: AppColors.textMuted, fontSize: 11)),
      ),
    );
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
    if (_submitted) {
      return _SuccessScreen(
          tournament: widget.tournament,
          teamName: _teamNameCtrl.text,
          teamTag: _teamTagCtrl.text);
    }

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
            child: const Icon(AppIcons.back,
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
          _StepHeader(
            steps: _steps,
            currentStep: _currentStep,
            onStepTap: (i) {
              if (i <= _currentStep) setState(() => _currentStep = i);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(_currentStep),
              ),
            ),
          ),
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

// ─── Step Header ──────────────────────────────────────────────────────────────
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
                        ? const Icon(Icons.check,
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
                  const Icon(AppIcons.back,
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
                    color: AppColors.cyan.withValues(alpha: 0.25),
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
                  isLast ? AppIcons.send : AppIcons.arrowFwd,
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
            icon: AppIcons.team,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'TEAM TAG',
            hint: 'e.g. T1, NAVI, SEN',
            controller: teamTagCtrl,
            icon: AppIcons.tag,
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
            icon: AppIcons.person,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'CONTACT EMAIL',
            hint: 'manager@team.gg',
            controller: contactEmailCtrl,
            icon: AppIcons.email,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'PHONE / DISCORD',
            hint: '+1 234 567 8900 or User#0000',
            controller: contactPhoneCtrl,
            icon: AppIcons.phone,
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

// ─── Step 4: Player Roster ────────────────────────────────────────────────────
class _Step4Roster extends StatefulWidget {
  final VoidCallback onUpload;
  const _Step4Roster({super.key, required this.onUpload});

  @override
  State<_Step4Roster> createState() => _Step4RosterState();
}

class _Step4RosterState extends State<_Step4Roster> {
  final List<_DynamicPlayerItem> _roster = [];

  @override
  void initState() {
    super.initState();
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
    setState(() => _roster.removeAt(index));
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(AppIcons.info, size: 16, color: AppColors.cyan),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'All active players and substitutes must provide details matching their official National ID or Passport.',
                style: AppText.caption.copyWith(height: 1.5),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
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
        GestureDetector(
          onTap: () => _addNewPlayer(),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.personAdd, color: AppColors.cyan, size: 18),
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

// ─── Shared form sub-components ───────────────────────────────────────────────
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
              icon: AppIcons.person,
              isRequired: false,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'NICKNAME / ALIAS',
              hint: 'e.g. kkOma',
              icon: AppIcons.gamepad,
              isRequired: false,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _FormField(
                  label: 'NATIONALITY',
                  hint: 'e.g. KR',
                  icon: AppIcons.flag,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'DATE OF BIRTH',
                  hint: 'YYYY-MM-DD',
                  icon: AppIcons.calendar,
                  isRequired: false,
                ),
              ),
            ]),
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
              ? AppColors.cyan.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                if (item.isCaptain)
                  const Icon(AppIcons.medal, size: 16, color: AppColors.purple),
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
              ]),
              GestureDetector(
                onTap: onRemove,
                child:
                    const Icon(AppIcons.delete, color: AppColors.red, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ThemedInput(
              hint: 'Legal Full Name',
              icon: AppIcons.badge,
              controller: item.fullNameCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _ThemedInput(
                  hint: 'In-Game Name (IGN)',
                  icon: AppIcons.gamepad,
                  controller: item.ignCtrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ThemedInput(
                  hint: 'Game UID',
                  icon: AppIcons.tag,
                  controller: item.uidCtrl),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _ThemedInput(
                  hint: 'Nationality',
                  icon: AppIcons.flag,
                  controller: item.nationalityCtrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ThemedInput(
                  hint: 'DOB (YYYY-MM-DD)',
                  icon: AppIcons.calendar,
                  controller: item.dobCtrl),
            ),
          ]),
          const SizedBox(height: 12),
          _ThemedInput(
              hint: 'In-Game Role (e.g. Support, IGL, Duelist)',
              icon: AppIcons.gamepad,
              controller: item.roleCtrl),
          const SizedBox(height: 14),
          Row(children: [
            Text('Substitute:',
                style:
                    AppText.caption.copyWith(color: AppColors.textSecondary)),
            Switch.adaptive(
              value: item.isSub,
              activeThumbColor: AppColors.cyan,
              onChanged: onTogglePosition,
            ),
            const Spacer(),
            Text('Team Captain:',
                style:
                    AppText.caption.copyWith(color: AppColors.textSecondary)),
            Switch.adaptive(
              value: item.isCaptain,
              activeThumbColor: AppColors.purple,
              onChanged: onToggleCaptain,
            ),
          ]),
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
          Row(children: [
            Text(label,
                style:
                    AppText.label.copyWith(fontSize: 11, letterSpacing: 1.2)),
            if (!isRequired)
              Text('  optional',
                  style: AppText.caption
                      .copyWith(color: AppColors.textMuted, fontSize: 10)),
          ]),
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
  Widget build(BuildContext context) => Column(children: [
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
                Icon(AppIcons.photo, color: AppColors.textSecondary, size: 24),
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
      ]);
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
                  const Icon(AppIcons.upload,
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
                    color: AppColors.cyan.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(AppIcons.check,
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
                  child: Row(children: [
                    const Icon(AppIcons.hourglass,
                        size: 16, color: AppColors.purple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your roster is pending review by the tournament organizers.',
                        style: AppText.caption.copyWith(height: 1.5),
                      ),
                    ),
                  ]),
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

// ─── Tournament List Screen Filter Tabs (ALL / LIVE / OPEN / UPCOMING) ────────
// Drop this widget into your tournament list/home screen where you have
// the existing filter tabs (All, Open, Upcoming). Replace those tabs with this.
class TournamentFilterTabs extends StatefulWidget {
  final ValueChanged<TournamentFilterType> onFilterChanged;
  final TournamentFilterType initialFilter;
  const TournamentFilterTabs({
    super.key,
    required this.onFilterChanged,
    this.initialFilter = TournamentFilterType.all,
  });

  @override
  State<TournamentFilterTabs> createState() => _TournamentFilterTabsState();
}

enum TournamentFilterType { all, live, open, upcoming }

class _TournamentFilterTabsState extends State<TournamentFilterTabs> {
  late TournamentFilterType _selected;

  static const _filters = [
    (TournamentFilterType.all, 'ALL', null),
    (TournamentFilterType.live, 'LIVE', AppIcons.live),
    (TournamentFilterType.open, 'OPEN', AppIcons.add),
    (TournamentFilterType.upcoming, 'UPCOMING', AppIcons.clock),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((f) {
          final (type, label, icon) = f;
          final isSelected = _selected == type;
          final isLive = type == TournamentFilterType.live;

          // Live tab gets a pulsing red dot accent
          final accentColor = isLive ? AppColors.red : AppColors.cyan;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selected = type);
              widget.onFilterChanged(type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.12)
                    : AppColors.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.5)
                      : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    // Live dot pulses with opacity animation handled by OS
                    Icon(
                      icon,
                      size: isLive ? 8 : 11,
                      color: isSelected ? accentColor : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    label,
                    style: AppText.label.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: isSelected ? accentColor : AppColors.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Helper: filter tournaments by type ───────────────────────────────────────
extension TournamentFilter on List<TournamentModel> {
  List<TournamentModel> filterBy(TournamentFilterType type) {
    return switch (type) {
      TournamentFilterType.all => this,
      TournamentFilterType.live =>
        where((t) => t.status == TournamentStatus.ongoing).toList(),
      TournamentFilterType.open =>
        where((t) => t.status == TournamentStatus.registration).toList(),
      TournamentFilterType.upcoming =>
        where((t) => t.status == TournamentStatus.upcoming).toList(),
    };
  }
}
