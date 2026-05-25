import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GameArenaApp());
}

// ============================================================
// 1. DESIGN TOKENS — Figma-matched
// ============================================================

class AC {
  // Backgrounds
  static const bg0 = Color(0xFF0D0D12); // deepest bg
  static const bg1 = Color(0xFF13131A); // scaffold bg
  static const bg2 = Color(0xFF1A1A24); // card bg
  static const bg3 = Color(0xFF22222E); // input / elevated card
  static const bg4 = Color(0xFF2A2A38); // hover / pressed

  // Accents — from Figma
  static const pink = Color(0xFFFF0080);
  static const purple = Color(0xFF8B00FF);
  static const cyan = Color(0xFF00E5FF);
  static const cyanDark = Color(0xFF00BCD4);

  // Semantic
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444);
  static const gold = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);

  // Text
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);

  // Border
  static const border = Color(0xFF2A2A3A);
  static const borderAccent = Color(0xFF3A3A50);

  // Gradients
  static const gradPrimary = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradPrimaryVert = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradCard = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF16161F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ============================================================
// 2. TYPOGRAPHY
// ============================================================

class AT {
  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AC.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AC.textPrimary,
    letterSpacing: -0.2,
  );

  static const subheading = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AC.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AC.textSecondary,
    height: 1.5,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AC.textMuted,
    letterSpacing: 1.2,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AC.textMuted,
  );
}

// ============================================================
// 3. SHARED DECORATIONS
// ============================================================

BoxDecoration cardDecor({Color? border, double radius = 16}) => BoxDecoration(
      gradient: AC.gradCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? AC.border, width: 1),
    );

BoxDecoration inputDecor({double radius = 12}) => BoxDecoration(
      color: AC.bg3,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AC.border, width: 1),
    );

InputDecoration fieldDecor({
  required String hint,
  IconData? icon,
  Widget? suffix,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: AT.caption.copyWith(color: AC.textMuted),
      prefixIcon: icon != null ? Icon(icon, color: AC.cyan, size: 18) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: AC.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AC.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AC.cyan, width: 1.5),
      ),
    );

// ============================================================
// 4. MODELS
// ============================================================

enum GameCtx {
  mlbb('Mobile Legends', '⚔️'),
  pubg('PUBG Mobile', '🪂'),
  freeFire('Free Fire', '🔥'),
  valorant('Valorant', '🎮');

  final String name;
  final String emoji;
  const GameCtx(this.name, this.emoji);
}

enum TourStatus { upcoming, open, live, closed }

enum ApprovalState { pending, approved, rejected }

enum UserStatus { active, suspended }

enum TourFormat { singleElim, doubleElim, groupStage, roundRobin }

class AppUser {
  final String id;
  String name;
  String email;
  UserStatus status;
  AppUser(
      {required this.id,
      required this.name,
      required this.email,
      this.status = UserStatus.active});
}

class TeamReg {
  final String id;
  String teamName;
  String region;
  List<String> roster;
  ApprovalState state;
  TeamReg(
      {required this.id,
      required this.teamName,
      required this.region,
      required this.roster,
      this.state = ApprovalState.pending});
}

class Tournament {
  final String id;
  String title;
  GameCtx game;
  TourStatus status;
  String prize;
  String type; // e.g. "Solo", "Duo", "Squad"
  TourFormat format;
  String? startDate;
  String? endDate;
  String? regDeadline;
  String? description;
  String? requirements;
  String? organizer;
  int maxTeams;
  bool isArchived;
  List<TeamReg> registrants;
  List<ScheduleEntry> schedules;
  List<BracketRound> bracketRounds;
  List<StandingEntry> standings;

  Tournament({
    required this.id,
    required this.title,
    required this.game,
    required this.status,
    required this.prize,
    this.type = 'Squad',
    this.format = TourFormat.singleElim,
    this.startDate,
    this.endDate,
    this.regDeadline,
    this.description,
    this.requirements,
    this.organizer,
    this.maxTeams = 16,
    this.isArchived = false,
    required this.registrants,
    List<ScheduleEntry>? schedules,
    List<BracketRound>? bracketRounds,
    List<StandingEntry>? standings,
  })  : schedules = schedules ?? [],
        bracketRounds = bracketRounds ?? [],
        standings = standings ?? [];
}

class ScheduleEntry {
  final String id;
  String round;
  String teamA;
  String teamB;
  String date;
  String time;
  String? venue;
  ScheduleEntry({
    required this.id,
    required this.round,
    required this.teamA,
    required this.teamB,
    required this.date,
    required this.time,
    this.venue,
  });
}

class MatchNode {
  final String id;
  String teamA;
  String teamB;
  int scoreA;
  int scoreB;
  bool isFinalized;
  String winner;
  String? date;
  String? time;

  MatchNode({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.isFinalized = false,
    this.winner = '',
    this.date,
    this.time,
  });
}

class BracketRound {
  final String id;
  String roundName;
  List<MatchNode> matches;
  BracketRound(
      {required this.id, required this.roundName, required this.matches});
}

class StandingEntry {
  final String id;
  String teamName;
  int played;
  int wins;
  int losses;
  int points;
  StandingEntry({
    required this.id,
    required this.teamName,
    this.played = 0,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
  });
}

// ============================================================
// 5. DATABASE
// ============================================================

class DB {
  static List<AppUser> users = [
    AppUser(id: 'u1', name: 'Nova Admin', email: 'admin@arena.gg'),
    AppUser(id: 'u2', name: 'Player One', email: 'p1@esports.gg'),
    AppUser(id: 'u3', name: 'Striker GG', email: 'striker@gg.com'),
  ];

  static List<Tournament> tournaments = [
    Tournament(
      id: 't1',
      title: 'MLBB World Championship 2026',
      game: GameCtx.mlbb,
      status: TourStatus.live,
      prize: '\$100,000',
      type: 'Squad',
      format: TourFormat.singleElim,
      startDate: '2026-06-01',
      endDate: '2026-06-30',
      regDeadline: '2026-05-28',
      description:
          'The premier Mobile Legends tournament bringing together top squads from across the globe to compete for the championship title and a massive prize pool.',
      requirements:
          'Teams must have 5 main players + 1 substitute. All players must be rank Mythic or above.',
      organizer: 'GameArena Official',
      maxTeams: 16,
      registrants: [
        TeamReg(
            id: 'r1',
            teamName: 'Evos Legends',
            region: 'ID',
            roster: ['Oura', 'Wannn', 'Rekt', 'Luminaire', 'Donkey'],
            state: ApprovalState.approved),
        TeamReg(
            id: 'r2',
            teamName: 'Blacklist Intl',
            region: 'PH',
            roster: ['OhMyV33nus', 'Wise', 'OHEB', 'Edward', 'Hadji'],
            state: ApprovalState.pending),
      ],
      schedules: [
        ScheduleEntry(
            id: 's1',
            round: 'Quarterfinals',
            teamA: 'Evos Legends',
            teamB: 'Blacklist Intl',
            date: '2026-06-10',
            time: '14:00',
            venue: 'Online'),
      ],
      bracketRounds: [
        BracketRound(
          id: 'b1',
          roundName: 'Quarterfinals',
          matches: [
            MatchNode(
                id: 'm1',
                teamA: 'Evos Legends',
                teamB: 'Blacklist Intl',
                date: '2026-06-10',
                time: '14:00'),
            MatchNode(
                id: 'm2',
                teamA: 'RRQ Hoshi',
                teamB: 'Echo PH',
                date: '2026-06-10',
                time: '16:00'),
          ],
        ),
        BracketRound(
          id: 'b2',
          roundName: 'Semifinals',
          matches: [
            MatchNode(id: 'm3', teamA: 'TBD', teamB: 'TBD'),
          ],
        ),
      ],
      standings: [
        StandingEntry(
            id: 'st1',
            teamName: 'Evos Legends',
            played: 6,
            wins: 5,
            losses: 1,
            points: 15),
        StandingEntry(
            id: 'st2',
            teamName: 'Blacklist Intl',
            played: 6,
            wins: 4,
            losses: 2,
            points: 12),
        StandingEntry(
            id: 'st3',
            teamName: 'RRQ Hoshi',
            played: 6,
            wins: 2,
            losses: 4,
            points: 6),
      ],
    ),
    Tournament(
      id: 't2',
      title: 'PUBG Mobile Global Series',
      game: GameCtx.pubg,
      status: TourStatus.open,
      prize: '\$50,000',
      type: 'Squad',
      format: TourFormat.groupStage,
      startDate: '2026-07-01',
      endDate: '2026-07-20',
      regDeadline: '2026-06-25',
      description:
          'Global PUBG Mobile series. Top squads compete across zones.',
      organizer: 'GameArena Official',
      maxTeams: 32,
      registrants: [],
    ),
  ];
}

// ============================================================
// 6. SHARED WIDGETS
// ============================================================

// Gradient button (pink-purple from Figma)
class GradButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final IconData? icon;
  final bool isLoading;
  const GradButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: width,
          height: 50,
          decoration: BoxDecoration(
            gradient: AC.gradPrimary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AC.pink.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
              else ...[
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5)),
              ]
            ],
          ),
        ),
      );
}

// Cyan outline button
class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  const OutlineBtn(
      {super.key,
      required this.label,
      required this.onTap,
      this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AC.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: c),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    color: c, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// Status badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child:
            Text(label, style: AT.label.copyWith(color: color, fontSize: 10)),
      );
}

// Section header with pink left bar
class SectionHdr extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHdr({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: AC.gradPrimaryVert,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: AT.label.copyWith(color: AC.textSecondary)),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
      );
}

// Empty state
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AC.bg3,
                shape: BoxShape.circle,
                border: Border.all(color: AC.border),
              ),
              child: Icon(icon, color: AC.textMuted, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: AT.subheading.copyWith(color: AC.textSecondary)),
            const SizedBox(height: 6),
            Text(subtitle, style: AT.caption, textAlign: TextAlign.center),
          ],
        ),
      );
}

// Confirm dialog (double check)
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  Color confirmColor = AC.red,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AC.bg2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: confirmColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Icon(icon, color: confirmColor, size: 24),
                ),
                const SizedBox(height: 16),
                Text(title,
                    style: AT.heading.copyWith(fontSize: 17),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(message, style: AT.body, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlineBtn(
                      label: 'Cancel',
                      color: AC.textSecondary,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: confirmColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(confirmLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

// ============================================================
// 7. APP ROOT
// ============================================================

class GameArenaApp extends StatelessWidget {
  const GameArenaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'GameArena Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AC.bg1,
          fontFamily: 'Inter',
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: AC.cyan,
            secondary: AC.pink,
            surface: AC.bg2,
          ),
        ),
        home: const AdminDashboard(),
      );
}

// ============================================================
// 8. ADMIN DASHBOARD — root with sign out
// ============================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  final _tabs = const [
    _NavItem(Icons.dashboard_rounded, 'Overview'),
    _NavItem(Icons.emoji_events_rounded, 'Tournaments'),
    _NavItem(Icons.how_to_reg_rounded, 'Approvals'),
    _NavItem(Icons.group_rounded, 'Users'),
    _NavItem(Icons.campaign_rounded, 'Broadcast'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg1,
      appBar: AppBar(
        backgroundColor: AC.bg0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(children: [
          // Logo
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AC.gradPrimary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.sports_esports_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GameArena',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AC.textPrimary,
                      letterSpacing: -0.3)),
              Text('Admin Console',
                  style:
                      AT.caption.copyWith(color: AC.textMuted, fontSize: 10)),
            ],
          ),
        ]),
        actions: [
          // Sign out button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _signOut(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AC.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AC.red.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.logout_rounded, color: AC.red, size: 16),
                  const SizedBox(width: 6),
                  Text('Sign Out',
                      style: AT.caption.copyWith(
                          color: AC.red, fontWeight: FontWeight.w600)),
                ]),
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
        children: const [
          AdminOverviewView(),
          AdminTournamentsView(),
          AdminApprovalsView(),
          AdminUsersView(),
          AdminBroadcastView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AC.bg0,
          border: Border(top: BorderSide(color: AC.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                final isActive = _tab == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tab = idx);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AC.pink.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: isActive ? AC.pink : AC.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w400,
                              color: isActive ? AC.pink : AC.textMuted,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
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

  void _signOut(BuildContext context) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of the admin console?',
      confirmLabel: 'Sign Out',
      confirmColor: AC.red,
      icon: Icons.logout_rounded,
    );
    if (confirm && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed out successfully'),
          backgroundColor: AC.bg3,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ============================================================
// 9. OVERVIEW TAB
// ============================================================

class AdminOverviewView extends StatelessWidget {
  const AdminOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final totalTours = DB.tournaments.length;
    final liveTours =
        DB.tournaments.where((t) => t.status == TourStatus.live).length;
    final totalUsers = DB.users.length;
    final pendingApprovals = DB.tournaments
        .expand((t) => t.registrants)
        .where((r) => r.state == ApprovalState.pending)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Welcome banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AC.gradPrimaryVert,
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome back,',
                style: AT.body.copyWith(color: Colors.white70)),
            const SizedBox(height: 4),
            const Text('Admin Console',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(
              'You have $pendingApprovals pending team approvals',
              style: AT.caption.copyWith(color: Colors.white70),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Stat cards
        SectionHdr(title: 'PLATFORM OVERVIEW'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
                label: 'TOURNAMENTS',
                value: '$totalTours',
                icon: Icons.emoji_events_rounded,
                color: AC.pink),
            _StatCard(
                label: 'LIVE NOW',
                value: '$liveTours',
                icon: Icons.circle,
                color: AC.green),
            _StatCard(
                label: 'TOTAL USERS',
                value: '$totalUsers',
                icon: Icons.group_rounded,
                color: AC.cyan),
            _StatCard(
                label: 'PENDING',
                value: '$pendingApprovals',
                icon: Icons.hourglass_top_rounded,
                color: AC.gold),
          ],
        ),
        const SizedBox(height: 24),

        // Recent tournaments
        SectionHdr(title: 'RECENT TOURNAMENTS'),
        ...DB.tournaments.take(3).map((t) => _TourOverviewCard(tour: t)),
        const SizedBox(height: 24),

        // Recent users
        SectionHdr(title: 'RECENT USERS'),
        ...DB.users.take(3).map((u) => _UserOverviewCard(user: u)),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecor(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: AT.label.copyWith(fontSize: 9)),
            ]),
          ],
        ),
      );
}

class _TourOverviewCard extends StatelessWidget {
  final Tournament tour;
  const _TourOverviewCard({required this.tour});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cardDecor(),
        child: Row(children: [
          Text(tour.game.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tour.title,
                  style: AT.subheading.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${tour.registrants.length} teams • ${tour.prize}',
                  style: AT.caption),
            ]),
          ),
          StatusBadge(
              label: tour.status.name.toUpperCase(),
              color: _tourStatusColor(tour.status)),
        ]),
      );

  Color _tourStatusColor(TourStatus s) => switch (s) {
        TourStatus.live => AC.red,
        TourStatus.open => AC.green,
        TourStatus.upcoming => AC.cyan,
        TourStatus.closed => AC.textMuted,
      };
}

class _UserOverviewCard extends StatelessWidget {
  final AppUser user;
  const _UserOverviewCard({required this.user});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cardDecor(),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AC.cyan.withOpacity(0.15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AC.cyan, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name, style: AT.subheading.copyWith(fontSize: 14)),
              Text(user.email, style: AT.caption),
            ]),
          ),
          StatusBadge(
            label: user.status.name.toUpperCase(),
            color: user.status == UserStatus.active ? AC.green : AC.red,
          ),
        ]),
      );
}

// ============================================================
// 10. TOURNAMENTS TAB
// ============================================================

class AdminTournamentsView extends StatefulWidget {
  const AdminTournamentsView({super.key});

  @override
  State<AdminTournamentsView> createState() => _AdminTournamentsViewState();
}

class _AdminTournamentsViewState extends State<AdminTournamentsView> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final list =
        DB.tournaments.where((t) => t.isArchived == _showArchived).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        // Toggle bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AC.border),
            ),
            child: Row(children: [
              _ToggleChip(
                label: 'Active',
                isActive: !_showArchived,
                onTap: () => setState(() => _showArchived = false),
              ),
              _ToggleChip(
                label: 'Archived',
                isActive: _showArchived,
                onTap: () => setState(() => _showArchived = true),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: _showArchived
                      ? 'No Archived Tournaments'
                      : 'No Tournaments',
                  subtitle: _showArchived
                      ? 'Archived tournaments will appear here'
                      : 'Tap + to create your first tournament')
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: list.length,
                  itemBuilder: (context, idx) => _TourCard(
                    tour: list[idx],
                    isArchived: _showArchived,
                    onRefresh: () => setState(() {}),
                    onEdit: () => _showTourForm(list[idx]),
                    onDelete: () => _deleteTour(list[idx]),
                    onArchive: () => setState(
                        () => list[idx].isArchived = !list[idx].isArchived),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TournamentDetailScreen(tour: list[idx]),
                      ),
                    ).then((_) => setState(() {})),
                  ),
                ),
        ),
      ]),
      floatingActionButton: _showArchived
          ? null
          : FloatingActionButton(
              backgroundColor: AC.pink,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showTourForm(null),
            ),
    );
  }

  void _deleteTour(Tournament tour) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Tournament',
      message:
          'Are you sure you want to permanently delete "${tour.title}"? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (ok && mounted) setState(() => DB.tournaments.remove(tour));
  }

  void _showTourForm(Tournament? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TourFormSheet(
        existing: existing,
        onSave: () => setState(() {}),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isActive ? AC.gradPrimary : null,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? Colors.white : AC.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
}

class _TourCard extends StatelessWidget {
  final Tournament tour;
  final bool isArchived;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onTap;
  const _TourCard({
    required this.tour,
    required this.isArchived,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    required this.onTap,
  });

  Color _statusColor(TourStatus s) => switch (s) {
        TourStatus.live => AC.red,
        TourStatus.open => AC.green,
        TourStatus.upcoming => AC.cyan,
        TourStatus.closed => AC.textMuted,
      };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecor(),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Game emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AC.bg3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(tour.game.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tour.title,
                          style: AT.subheading.copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(tour.game.name, style: AT.caption),
                        const Text('  •  ',
                            style: TextStyle(color: AC.textMuted)),
                        Text(tour.prize,
                            style: AT.caption.copyWith(
                                color: AC.gold, fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AC.textSecondary, size: 20),
                  color: AC.bg3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'archive') onArchive();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (!isArchived)
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, color: AC.cyan, size: 16),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ])),
                    PopupMenuItem(
                        value: 'archive',
                        child: Row(children: [
                          Icon(
                              isArchived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              color: AC.gold,
                              size: 16),
                          const SizedBox(width: 10),
                          Text(isArchived ? 'Restore' : 'Archive'),
                        ])),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, color: AC.red, size: 16),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: AC.red)),
                        ])),
                  ],
                ),
              ]),
            ),
            // Bottom status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F18),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: AC.border)),
              ),
              child: Row(children: [
                StatusBadge(
                    label: tour.status.name.toUpperCase(),
                    color: _statusColor(tour.status)),
                const Spacer(),
                Icon(Icons.groups_rounded, size: 14, color: AC.textMuted),
                const SizedBox(width: 4),
                Text('${tour.registrants.length}/${tour.maxTeams} teams',
                    style: AT.caption),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AC.textMuted),
              ]),
            ),
          ]),
        ),
      );
}

// Tournament creation/edit form
class _TourFormSheet extends StatefulWidget {
  final Tournament? existing;
  final VoidCallback onSave;
  const _TourFormSheet({this.existing, required this.onSave});

  @override
  State<_TourFormSheet> createState() => _TourFormSheetState();
}

class _TourFormSheetState extends State<_TourFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _prize;
  late final TextEditingController _desc;
  late final TextEditingController _req;
  late final TextEditingController _org;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;
  late final TextEditingController _regDeadline;
  late GameCtx _game;
  late TourStatus _status;
  late TourFormat _format;
  late String _type;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _prize = TextEditingController(text: e?.prize ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _req = TextEditingController(text: e?.requirements ?? '');
    _org = TextEditingController(text: e?.organizer ?? '');
    _startDate = TextEditingController(text: e?.startDate ?? '');
    _endDate = TextEditingController(text: e?.endDate ?? '');
    _regDeadline = TextEditingController(text: e?.regDeadline ?? '');
    _game = e?.game ?? GameCtx.mlbb;
    _status = e?.status ?? TourStatus.upcoming;
    _format = e?.format ?? TourFormat.singleElim;
    _type = e?.type ?? 'Squad';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AC.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
                widget.existing == null
                    ? 'CREATE TOURNAMENT'
                    : 'EDIT TOURNAMENT',
                style: AT.heading),
            const SizedBox(height: 20),

            // Banner upload placeholder
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AC.bg3,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AC.border, style: BorderStyle.solid),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_rounded,
                          color: AC.textMuted),
                      const SizedBox(height: 6),
                      Text('Tap to upload Banner / Logo', style: AT.caption),
                    ]),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
                controller: _title,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Tournament Title',
                    icon: Icons.emoji_events_rounded)),
            const SizedBox(height: 12),
            TextField(
                controller: _prize,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Prize Pool (e.g. \$10,000)',
                    icon: Icons.monetization_on_rounded)),
            const SizedBox(height: 12),
            TextField(
                controller: _desc,
                maxLines: 3,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Tournament description...',
                    icon: Icons.description_rounded)),
            const SizedBox(height: 12),
            TextField(
                controller: _req,
                maxLines: 2,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Requirements / eligibility...',
                    icon: Icons.rule_rounded)),
            const SizedBox(height: 12),
            TextField(
                controller: _org,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Organizer name', icon: Icons.business_rounded)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                    controller: _startDate,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                        hint: 'Start (YYYY-MM-DD)',
                        icon: Icons.calendar_today_rounded)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: _endDate,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                        hint: 'End (YYYY-MM-DD)', icon: Icons.event_rounded)),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
                controller: _regDeadline,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Registration Deadline (YYYY-MM-DD)',
                    icon: Icons.timer_rounded)),
            const SizedBox(height: 12),

            // Dropdowns row
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<GameCtx>(
                  value: _game,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                      hint: 'Game', icon: Icons.videogame_asset_rounded),
                  items: GameCtx.values
                      .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text('${g.emoji} ${g.name}',
                              overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _game = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<TourStatus>(
                  value: _status,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                      hint: 'Status', icon: Icons.radio_button_checked_rounded),
                  items: TourStatus.values
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text(s.name.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<TourFormat>(
                  value: _format,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                      hint: 'Format', icon: Icons.account_tree_rounded),
                  items: [
                    const DropdownMenuItem(
                        value: TourFormat.singleElim,
                        child: Text('Single Elim')),
                    const DropdownMenuItem(
                        value: TourFormat.doubleElim,
                        child: Text('Double Elim')),
                    const DropdownMenuItem(
                        value: TourFormat.groupStage,
                        child: Text('Group Stage')),
                    const DropdownMenuItem(
                        value: TourFormat.roundRobin,
                        child: Text('Round Robin')),
                  ],
                  onChanged: (v) => setState(() => _format = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration:
                      fieldDecor(hint: 'Type', icon: Icons.people_rounded),
                  items: ['Solo', 'Duo', 'Squad', 'Team']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            GradButton(
              label: widget.existing == null
                  ? 'PUBLISH TOURNAMENT'
                  : 'SAVE CHANGES',
              width: double.infinity,
              icon: Icons.check_rounded,
              onTap: () {
                final e = widget.existing;
                if (e != null) {
                  e.title = _title.text;
                  e.prize = _prize.text;
                  e.game = _game;
                  e.status = _status;
                  e.format = _format;
                  e.type = _type;
                  e.description = _desc.text;
                  e.requirements = _req.text;
                  e.organizer = _org.text;
                  e.startDate = _startDate.text;
                  e.endDate = _endDate.text;
                  e.regDeadline = _regDeadline.text;
                } else {
                  DB.tournaments.add(Tournament(
                    id: 't_${DateTime.now().millisecondsSinceEpoch}',
                    title: _title.text,
                    game: _game,
                    status: _status,
                    prize: _prize.text,
                    format: _format,
                    type: _type,
                    description: _desc.text,
                    requirements: _req.text,
                    organizer: _org.text,
                    startDate: _startDate.text,
                    endDate: _endDate.text,
                    regDeadline: _regDeadline.text,
                    registrants: [],
                  ));
                }
                widget.onSave();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 11. TOURNAMENT DETAIL SCREEN
// ============================================================

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tour;
  const TournamentDetailScreen({super.key, required this.tour});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tc;
  static const _tabLabels = [
    'OVERVIEW',
    'SCHEDULE',
    'BRACKET',
    'TEAMS',
    'STANDINGS',
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Color _statusColor(TourStatus s) => switch (s) {
        TourStatus.live => AC.red,
        TourStatus.open => AC.green,
        TourStatus.upcoming => AC.cyan,
        TourStatus.closed => AC.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final t = widget.tour;
    return Scaffold(
      backgroundColor: AC.bg1,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AC.bg0,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AC.bg3,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AC.border),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 15, color: AC.textSecondary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _TourFormSheet(
                      existing: t,
                      onSave: () => setState(() {}),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AC.bg3,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AC.border),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 16, color: AC.textSecondary),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _TourHero(tour: t),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: Container(
                color: AC.bg0,
                child: TabBar(
                  controller: _tc,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AC.pink,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: AC.border,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                  labelStyle: AT.label.copyWith(
                      color: AC.pink, fontSize: 11, letterSpacing: 1.5),
                  unselectedLabelStyle: AT.label.copyWith(
                      color: AC.textMuted, fontSize: 11, letterSpacing: 1.5),
                  tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tc,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DetailOverviewTab(tour: t),
            _DetailScheduleTab(tour: t, onUpdate: () => setState(() {})),
            _DetailBracketTab(tour: t, onUpdate: () => setState(() {})),
            _DetailTeamsTab(tour: t, onUpdate: () => setState(() {})),
            _DetailStandingsTab(tour: t, onUpdate: () => setState(() {})),
          ],
        ),
      ),
    );
  }
}

class _TourHero extends StatelessWidget {
  final Tournament tour;
  const _TourHero({required this.tour});

  Color _statusColor(TourStatus s) => switch (s) {
        TourStatus.live => AC.red,
        TourStatus.open => AC.green,
        TourStatus.upcoming => AC.cyan,
        TourStatus.closed => AC.textMuted,
      };

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AC.bg2, AC.bg0],
          ),
        ),
        child: Stack(children: [
          // Ghost emoji
          Positioned(
            right: -10,
            bottom: 40,
            child: Opacity(
              opacity: 0.05,
              child:
                  Text(tour.game.emoji, style: const TextStyle(fontSize: 130)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(children: [
                  StatusBadge(
                      label: tour.status.name.toUpperCase(),
                      color: _statusColor(tour.status)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AC.bg3,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AC.border),
                    ),
                    child: Text('${tour.game.emoji}  ${tour.game.name}',
                        style: AT.label
                            .copyWith(color: AC.textSecondary, fontSize: 10)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(tour.title, style: AT.display.copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Row(children: [
                  _StatPill(
                      icon: Icons.emoji_events_rounded,
                      label: tour.prize,
                      color: AC.gold),
                  const SizedBox(width: 8),
                  _StatPill(
                      icon: Icons.groups_rounded,
                      label:
                          '${tour.registrants.length}/${tour.maxTeams} teams',
                      color: AC.cyan),
                ]),
              ],
            ),
          ),
        ]),
      );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: AT.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}

// ── Overview Tab ──────────────────────────────────────────────

class _DetailOverviewTab extends StatelessWidget {
  final Tournament tour;
  const _DetailOverviewTab({required this.tour});

  @override
  Widget build(BuildContext context) {
    final t = tour;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stat cards row
        Row(children: [
          _MiniStat(
              label: 'PRIZE',
              value: t.prize,
              color: AC.gold,
              icon: Icons.emoji_events_rounded),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'TEAMS',
              value: '${t.registrants.length}/${t.maxTeams}',
              color: AC.cyan,
              icon: Icons.groups_rounded),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'TYPE',
              value: t.type,
              color: AC.purple,
              icon: Icons.people_rounded),
        ]),
        const SizedBox(height: 24),

        // About
        SectionHdr(title: 'ABOUT'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecor(),
          child: Text(
              t.description?.isNotEmpty == true
                  ? t.description!
                  : 'No description provided.',
              style: AT.body.copyWith(height: 1.7)),
        ),
        const SizedBox(height: 24),

        // Details
        SectionHdr(title: 'TOURNAMENT DETAILS'),
        Container(
          decoration: cardDecor(),
          child: Column(children: [
            _DetailRow(
                icon: Icons.sports_esports_rounded,
                label: 'Game',
                value: '${t.game.emoji} ${t.game.name}'),
            _DetailRow(
                icon: Icons.account_tree_rounded,
                label: 'Format',
                value: _formatLabel(t.format)),
            _DetailRow(
                icon: Icons.people_rounded, label: 'Type', value: t.type),
            _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Start Date',
                value: t.startDate?.isNotEmpty == true ? t.startDate! : 'TBA'),
            _DetailRow(
                icon: Icons.event_rounded,
                label: 'End Date',
                value: t.endDate?.isNotEmpty == true ? t.endDate! : 'TBA'),
            _DetailRow(
                icon: Icons.timer_rounded,
                label: 'Reg. Deadline',
                value:
                    t.regDeadline?.isNotEmpty == true ? t.regDeadline! : 'TBA'),
            _DetailRow(
                icon: Icons.business_rounded,
                label: 'Organizer',
                value: t.organizer?.isNotEmpty == true ? t.organizer! : 'TBA',
                isLast: true),
          ]),
        ),

        if (t.requirements?.isNotEmpty == true) ...[
          const SizedBox(height: 24),
          SectionHdr(title: 'REQUIREMENTS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecor(border: AC.cyan.withOpacity(0.2)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.rule_rounded, color: AC.cyan, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child:
                    Text(t.requirements!, style: AT.body.copyWith(height: 1.6)),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  String _formatLabel(TourFormat f) => switch (f) {
        TourFormat.singleElim => 'Single Elimination',
        TourFormat.doubleElim => 'Double Elimination',
        TourFormat.groupStage => 'Group Stage',
        TourFormat.roundRobin => 'Round Robin',
      };
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStat(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: cardDecor(border: color.withOpacity(0.2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: color),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(label, style: AT.label.copyWith(fontSize: 9)),
            ],
          ),
        ),
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AC.border, width: 0.5)),
        ),
        child: Row(children: [
          Icon(icon, size: 15, color: AC.cyan),
          const SizedBox(width: 12),
          Text(label, style: AT.caption.copyWith(color: AC.textMuted)),
          const Spacer(),
          Text(value,
              style: AT.body.copyWith(
                  color: AC.textPrimary, fontWeight: FontWeight.w500)),
        ]),
      );
}

// ── Schedule Tab ──────────────────────────────────────────────

class _DetailScheduleTab extends StatefulWidget {
  final Tournament tour;
  final VoidCallback onUpdate;
  const _DetailScheduleTab({required this.tour, required this.onUpdate});

  @override
  State<_DetailScheduleTab> createState() => _DetailScheduleTabState();
}

class _DetailScheduleTabState extends State<_DetailScheduleTab> {
  @override
  Widget build(BuildContext context) {
    final schedules = widget.tour.schedules;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: schedules.isEmpty
          ? const EmptyState(
              icon: Icons.schedule_rounded,
              title: 'No Matches Scheduled',
              subtitle: 'Add your first match schedule below')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: schedules.length,
              itemBuilder: (context, idx) {
                final s = schedules[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: cardDecor(),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AC.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AC.cyan.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.schedule_rounded,
                              color: AC.cyan, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.round,
                                    style: AT.caption.copyWith(
                                        color: AC.pink,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${s.teamA}  vs  ${s.teamB}',
                                    style:
                                        AT.subheading.copyWith(fontSize: 14)),
                                const SizedBox(height: 3),
                                Text('${s.date}  ${s.time}', style: AT.caption),
                              ]),
                        ),
                        // Action buttons
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AC.textSecondary, size: 20),
                          color: AC.bg3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) async {
                            if (val == 'edit') {
                              _showScheduleForm(existing: s, idx: idx);
                            } else if (val == 'delete') {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Delete Match',
                                message: 'Remove this match from the schedule?',
                              );
                              if (ok) {
                                setState(
                                    () => widget.tour.schedules.removeAt(idx));
                                widget.onUpdate();
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined,
                                      color: AC.cyan, size: 15),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ])),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      color: AC.red, size: 15),
                                  SizedBox(width: 10),
                                  Text('Delete',
                                      style: TextStyle(color: AC.red)),
                                ])),
                          ],
                        ),
                      ]),
                    ),
                    if (s.venue != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F0F18),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                          border: Border(top: BorderSide(color: AC.border)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: AC.textMuted),
                          const SizedBox(width: 4),
                          Text(s.venue!, style: AT.caption),
                        ]),
                      ),
                  ]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AC.pink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showScheduleForm(),
      ),
    );
  }

  void _showScheduleForm({ScheduleEntry? existing, int? idx}) {
    final round = TextEditingController(text: existing?.round ?? '');
    final teamA = TextEditingController(text: existing?.teamA ?? '');
    final teamB = TextEditingController(text: existing?.teamB ?? '');
    final date = TextEditingController(text: existing?.date ?? '');
    final time = TextEditingController(text: existing?.time ?? '');
    final venue = TextEditingController(text: existing?.venue ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AC.border,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(existing == null ? 'ADD SCHEDULE' : 'EDIT SCHEDULE',
                  style: AT.heading),
              const SizedBox(height: 20),
              TextField(
                  controller: round,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                      hint: 'Round / Stage', icon: Icons.flag_rounded)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                      controller: teamA,
                      style: const TextStyle(color: AC.textPrimary),
                      decoration: fieldDecor(
                          hint: 'Team A', icon: Icons.group_rounded)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      controller: teamB,
                      style: const TextStyle(color: AC.textPrimary),
                      decoration: fieldDecor(
                          hint: 'Team B', icon: Icons.group_rounded)),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                      controller: date,
                      style: const TextStyle(color: AC.textPrimary),
                      decoration: fieldDecor(
                          hint: 'Date (YYYY-MM-DD)',
                          icon: Icons.calendar_today_rounded)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      controller: time,
                      style: const TextStyle(color: AC.textPrimary),
                      decoration: fieldDecor(
                          hint: 'Time (HH:MM)',
                          icon: Icons.access_time_rounded)),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: venue,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                      hint: 'Venue (optional)',
                      icon: Icons.location_on_rounded)),
              const SizedBox(height: 24),
              GradButton(
                label: existing == null ? 'ADD MATCH' : 'SAVE CHANGES',
                width: double.infinity,
                onTap: () {
                  if (existing != null && idx != null) {
                    setState(() {
                      existing.round = round.text;
                      existing.teamA = teamA.text;
                      existing.teamB = teamB.text;
                      existing.date = date.text;
                      existing.time = time.text;
                      existing.venue = venue.text.isEmpty ? null : venue.text;
                    });
                  } else {
                    setState(() {
                      widget.tour.schedules.add(ScheduleEntry(
                        id: DateTime.now().toString(),
                        round: round.text,
                        teamA: teamA.text,
                        teamB: teamB.text,
                        date: date.text,
                        time: time.text,
                        venue: venue.text.isEmpty ? null : venue.text,
                      ));
                    });
                  }
                  widget.onUpdate();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bracket Tab ───────────────────────────────────────────────

class _DetailBracketTab extends StatefulWidget {
  final Tournament tour;
  final VoidCallback onUpdate;
  const _DetailBracketTab({required this.tour, required this.onUpdate});

  @override
  State<_DetailBracketTab> createState() => _DetailBracketTabState();
}

class _DetailBracketTabState extends State<_DetailBracketTab> {
  @override
  Widget build(BuildContext context) {
    final rounds = widget.tour.bracketRounds;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: rounds.isEmpty
          ? const EmptyState(
              icon: Icons.account_tree_rounded,
              title: 'No Bracket Yet',
              subtitle: 'Add rounds to build the bracket')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rounds.asMap().entries.map((e) {
                    final roundIdx = e.key;
                    final round = e.value;
                    final isLast = roundIdx == rounds.length - 1;
                    return _BracketRoundCol(
                      round: round,
                      roundIdx: roundIdx,
                      isLast: isLast,
                      onDeleteRound: () => _deleteRound(round, roundIdx),
                      onEditMatch: (m) => _editMatch(m, roundIdx),
                      onDeleteMatch: (m) => _deleteMatch(m, round),
                    );
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AC.pink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD ROUND',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        onPressed: _addRound,
      ),
    );
  }

  void _addRound() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('ADD ROUND', style: AT.heading),
            const SizedBox(height: 20),
            TextField(
                controller: ctrl,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                    hint: 'Round name (e.g. Semifinals)',
                    icon: Icons.flag_rounded)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlineBtn(
                      label: 'Cancel',
                      color: AC.textSecondary,
                      onTap: () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              Expanded(
                child: GradButton(
                  label: 'Add',
                  onTap: () {
                    setState(() {
                      widget.tour.bracketRounds.add(BracketRound(
                        id: DateTime.now().toString(),
                        roundName: ctrl.text,
                        matches: [
                          MatchNode(id: 'm_new', teamA: 'TBD', teamB: 'TBD')
                        ],
                      ));
                    });
                    widget.onUpdate();
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _deleteRound(BracketRound round, int roundIdx) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Round',
      message: 'Delete "${round.roundName}" and all its matches?',
    );
    if (ok) {
      setState(() => widget.tour.bracketRounds.removeAt(roundIdx));
      widget.onUpdate();
    }
  }

  void _deleteMatch(MatchNode m, BracketRound round) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Match',
      message: 'Remove "${m.teamA} vs ${m.teamB}" from this round?',
    );
    if (ok) {
      setState(() => round.matches.remove(m));
      widget.onUpdate();
    }
  }

  void _editMatch(MatchNode m, int roundIdx) {
    final sA = TextEditingController(text: m.scoreA.toString());
    final sB = TextEditingController(text: m.scoreB.toString());
    final tA = TextEditingController(text: m.teamA);
    final tB = TextEditingController(text: m.teamB);
    final date = TextEditingController(text: m.date ?? '');
    final time = TextEditingController(text: m.time ?? '');
    String win = m.teamA;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AC.bg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AC.border,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('EDIT MATCH', style: AT.heading),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: tA,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(hint: 'Team A')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                        controller: tB,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(hint: 'Team B')),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: date,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                            hint: 'Date (YYYY-MM-DD)',
                            icon: Icons.calendar_today_rounded)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                        controller: time,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                            hint: 'Time (HH:MM)',
                            icon: Icons.access_time_rounded)),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: sA,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                            hint: 'Score A', icon: Icons.scoreboard_rounded)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                        controller: sB,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                            hint: 'Score B', icon: Icons.scoreboard_rounded)),
                  ),
                ]),
                const SizedBox(height: 16),
                Text('SELECT WINNER', style: AT.label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: win,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                      hint: 'Winner', icon: Icons.emoji_events_rounded),
                  items: [tA.text, tB.text]
                      .where((s) => s.isNotEmpty)
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setS(() => win = v!),
                ),
                const SizedBox(height: 24),
                GradButton(
                  label: 'SAVE & ADVANCE',
                  width: double.infinity,
                  onTap: () {
                    setState(() {
                      m.teamA = tA.text;
                      m.teamB = tB.text;
                      m.scoreA = int.tryParse(sA.text) ?? 0;
                      m.scoreB = int.tryParse(sB.text) ?? 0;
                      m.isFinalized = true;
                      m.winner = win;
                      m.date = date.text.isEmpty ? null : date.text;
                      m.time = time.text.isEmpty ? null : time.text;

                      // Auto advance
                      final rounds = widget.tour.bracketRounds;
                      if (roundIdx + 1 < rounds.length) {
                        final next = rounds[roundIdx + 1];
                        if (next.matches.isNotEmpty) {
                          if (next.matches[0].teamA == 'TBD') {
                            next.matches[0].teamA = win;
                          } else if (next.matches[0].teamB == 'TBD') {
                            next.matches[0].teamB = win;
                          }
                        }
                      }
                    });
                    widget.onUpdate();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BracketRoundCol extends StatelessWidget {
  final BracketRound round;
  final int roundIdx;
  final bool isLast;
  final VoidCallback onDeleteRound;
  final void Function(MatchNode) onEditMatch;
  final void Function(MatchNode) onDeleteMatch;

  const _BracketRoundCol({
    required this.round,
    required this.roundIdx,
    required this.isLast,
    required this.onDeleteRound,
    required this.onEditMatch,
    required this.onDeleteMatch,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                // Round header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1A3E), Color(0xFF1E1E2E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AC.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          round.roundName.toUpperCase(),
                          style:
                              AT.label.copyWith(color: AC.purple, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDeleteRound,
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: AC.red),
                      ),
                    ],
                  ),
                ),
                // Matches
                ...round.matches.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color:
                            m.isFinalized ? AC.green.withOpacity(0.05) : AC.bg2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: m.isFinalized
                              ? AC.green.withOpacity(0.3)
                              : AC.border,
                        ),
                      ),
                      child: Column(children: [
                        // Match time
                        if (m.date != null || m.time != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: AC.border)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 10, color: AC.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${m.date ?? ''} ${m.time ?? ''}'.trim(),
                                style: AT.caption.copyWith(fontSize: 9),
                              ),
                            ]),
                          ),
                        // Team A
                        _BracketSlotRow(
                            name: m.teamA,
                            score: m.scoreA,
                            isWinner: m.isFinalized && m.winner == m.teamA),
                        Container(height: 0.5, color: AC.border),
                        // Team B
                        _BracketSlotRow(
                            name: m.teamB,
                            score: m.scoreB,
                            isWinner: m.isFinalized && m.winner == m.teamB),
                        // Actions
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: AC.border)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => onEditMatch(m),
                                child: Row(children: [
                                  const Icon(Icons.edit_rounded,
                                      size: 12, color: AC.cyan),
                                  const SizedBox(width: 4),
                                  Text('Edit',
                                      style: AT.caption.copyWith(
                                          color: AC.cyan, fontSize: 10)),
                                ]),
                              ),
                              GestureDetector(
                                onTap: () => onDeleteMatch(m),
                                child: const Icon(Icons.delete_outline_rounded,
                                    size: 14, color: AC.red),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    )),
              ],
            ),
          ),
          if (!isLast)
            const SizedBox(
              width: 32,
              child: Center(
                child: Icon(Icons.chevron_right_rounded,
                    color: AC.border, size: 20),
              ),
            ),
        ],
      );
}

class _BracketSlotRow extends StatelessWidget {
  final String name;
  final int score;
  final bool isWinner;
  const _BracketSlotRow(
      {required this.name, required this.score, required this.isWinner});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isWinner ? AC.green.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(Icons.emoji_events_rounded, size: 11, color: AC.gold),
            ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                color: isWinner ? AC.textPrimary : AC.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isWinner ? AC.green : AC.textMuted,
            ),
          ),
        ]),
      );
}

// ── Teams Tab ─────────────────────────────────────────────────

class _DetailTeamsTab extends StatefulWidget {
  final Tournament tour;
  final VoidCallback onUpdate;
  const _DetailTeamsTab({required this.tour, required this.onUpdate});

  @override
  State<_DetailTeamsTab> createState() => _DetailTeamsTabState();
}

class _DetailTeamsTabState extends State<_DetailTeamsTab> {
  @override
  Widget build(BuildContext context) {
    final teams = widget.tour.registrants;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: teams.isEmpty
          ? const EmptyState(
              icon: Icons.groups_outlined,
              title: 'No Teams Yet',
              subtitle: 'Registered teams will appear here')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: teams.length,
              itemBuilder: (context, idx) {
                final team = teams[idx];
                final stateColor = switch (team.state) {
                  ApprovalState.approved => AC.green,
                  ApprovalState.rejected => AC.red,
                  ApprovalState.pending => AC.gold,
                };
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: cardDecor(border: stateColor.withOpacity(0.25)),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: stateColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: stateColor.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              team.teamName.isNotEmpty ? team.teamName[0] : '?',
                              style: TextStyle(
                                  color: stateColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(team.teamName,
                                    style:
                                        AT.subheading.copyWith(fontSize: 15)),
                                const SizedBox(height: 3),
                                Text('Region: ${team.region}',
                                    style: AT.caption),
                              ]),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AC.textSecondary, size: 20),
                          color: AC.bg3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) async {
                            if (val == 'approve') {
                              setState(
                                  () => team.state = ApprovalState.approved);
                            } else if (val == 'reject') {
                              setState(
                                  () => team.state = ApprovalState.rejected);
                            } else if (val == 'pending') {
                              setState(
                                  () => team.state = ApprovalState.pending);
                            } else if (val == 'delete') {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Remove Team',
                                message:
                                    'Remove "${team.teamName}" from this tournament?',
                              );
                              if (ok) {
                                setState(() =>
                                    widget.tour.registrants.removeAt(idx));
                                widget.onUpdate();
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'approve',
                                child: Row(children: [
                                  Icon(Icons.check_circle_outline,
                                      color: AC.green, size: 15),
                                  SizedBox(width: 10),
                                  Text('Approve',
                                      style: TextStyle(color: AC.green)),
                                ])),
                            const PopupMenuItem(
                                value: 'reject',
                                child: Row(children: [
                                  Icon(Icons.cancel_outlined,
                                      color: AC.red, size: 15),
                                  SizedBox(width: 10),
                                  Text('Reject',
                                      style: TextStyle(color: AC.red)),
                                ])),
                            const PopupMenuItem(
                                value: 'pending',
                                child: Row(children: [
                                  Icon(Icons.hourglass_top_rounded,
                                      color: AC.gold, size: 15),
                                  SizedBox(width: 10),
                                  Text('Set Pending',
                                      style: TextStyle(color: AC.gold)),
                                ])),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      color: AC.red, size: 15),
                                  SizedBox(width: 10),
                                  Text('Remove Team',
                                      style: TextStyle(color: AC.red)),
                                ])),
                          ],
                        ),
                      ]),
                    ),
                    // Status + roster
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F0F18),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(16)),
                        border: Border(top: BorderSide(color: AC.border)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge(
                                label: team.state.name.toUpperCase(),
                                color: stateColor),
                            if (team.roster.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text('ROSTER',
                                  style: AT.label.copyWith(fontSize: 9)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: team.roster
                                    .map((p) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AC.bg3,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border:
                                                Border.all(color: AC.border),
                                          ),
                                          child: Text(p,
                                              style: AT.caption
                                                  .copyWith(fontSize: 11)),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ]),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}

// ── Standings Tab ─────────────────────────────────────────────

class _DetailStandingsTab extends StatefulWidget {
  final Tournament tour;
  final VoidCallback onUpdate;
  const _DetailStandingsTab({required this.tour, required this.onUpdate});

  @override
  State<_DetailStandingsTab> createState() => _DetailStandingsTabState();
}

class _DetailStandingsTabState extends State<_DetailStandingsTab> {
  void _sort() {
    widget.tour.standings.sort((a, b) => b.points.compareTo(a.points));
  }

  @override
  Widget build(BuildContext context) {
    _sort();
    final standings = widget.tour.standings;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: standings.isEmpty
          ? const EmptyState(
              icon: Icons.leaderboard_rounded,
              title: 'No Standings Yet',
              subtitle: 'Standings will appear once matches begin')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AC.bg2,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(
                      top: BorderSide(color: AC.border),
                      left: BorderSide(color: AC.border),
                      right: BorderSide(color: AC.border),
                    ),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 28),
                    Expanded(
                        child: Text('TEAM',
                            style: AT.label.copyWith(fontSize: 9))),
                    for (final l in ['P', 'W', 'L', 'PTS'])
                      SizedBox(
                        width: l == 'PTS' ? 42 : 28,
                        child: Text(l,
                            style: AT.label.copyWith(
                                fontSize: 9,
                                color: l == 'PTS' ? AC.cyan : AC.textMuted),
                            textAlign: TextAlign.center),
                      ),
                    const SizedBox(width: 36),
                  ]),
                ),
                // Rows
                ...standings.asMap().entries.map((e) {
                  final rank = e.key + 1;
                  final s = e.value;
                  final Color rankColor = rank == 1
                      ? AC.gold
                      : rank == 2
                          ? const Color(0xFFC0C0C0)
                          : rank == 3
                              ? const Color(0xFFCD7F32)
                              : AC.textMuted;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: rank <= 3 ? AC.cyan.withOpacity(0.02) : AC.bg1,
                      border: const Border(
                        left: BorderSide(color: AC.border),
                        right: BorderSide(color: AC.border),
                        bottom: BorderSide(color: AC.border),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(
                        width: 28,
                        child: Text('$rank',
                            style: TextStyle(
                                color: rankColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Row(children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AC.bg3,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AC.border),
                            ),
                            child: Center(
                              child: Text(
                                s.teamName.length >= 2
                                    ? s.teamName.substring(0, 2)
                                    : s.teamName,
                                style: AT.label
                                    .copyWith(color: AC.cyan, fontSize: 9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(s.teamName,
                                  style: AT.body.copyWith(
                                      color: AC.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                      SizedBox(
                          width: 28,
                          child: Text('${s.played}',
                              style: AT.body.copyWith(fontSize: 13),
                              textAlign: TextAlign.center)),
                      SizedBox(
                          width: 28,
                          child: Text('${s.wins}',
                              style: AT.body
                                  .copyWith(color: AC.green, fontSize: 13),
                              textAlign: TextAlign.center)),
                      SizedBox(
                          width: 28,
                          child: Text('${s.losses}',
                              style:
                                  AT.body.copyWith(color: AC.red, fontSize: 13),
                              textAlign: TextAlign.center)),
                      SizedBox(
                          width: 42,
                          child: Text('${s.points}',
                              style: AT.heading
                                  .copyWith(color: AC.cyan, fontSize: 15),
                              textAlign: TextAlign.center)),
                      SizedBox(
                        width: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _editStanding(s),
                              child: const Icon(Icons.edit_rounded,
                                  size: 15, color: AC.cyan),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _deleteStanding(s),
                              child: const Icon(Icons.delete_outline_rounded,
                                  size: 15, color: AC.red),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 20),
              ]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AC.pink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _addStanding,
      ),
    );
  }

  void _addStanding() {
    _standingForm(null);
  }

  void _editStanding(StandingEntry s) {
    _standingForm(s);
  }

  void _standingForm(StandingEntry? existing) {
    final name = TextEditingController(text: existing?.teamName ?? '');
    final played =
        TextEditingController(text: existing?.played.toString() ?? '0');
    final wins = TextEditingController(text: existing?.wins.toString() ?? '0');
    final losses =
        TextEditingController(text: existing?.losses.toString() ?? '0');
    final points =
        TextEditingController(text: existing?.points.toString() ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AC.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(existing == null ? 'ADD TEAM' : 'EDIT STANDING',
                style: AT.heading),
            const SizedBox(height: 20),
            TextField(
                controller: name,
                style: const TextStyle(color: AC.textPrimary),
                decoration:
                    fieldDecor(hint: 'Team Name', icon: Icons.group_rounded)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                    controller: played,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration:
                        fieldDecor(hint: 'Played', icon: Icons.sports_rounded)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: wins,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration:
                        fieldDecor(hint: 'Wins', icon: Icons.thumb_up_rounded)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: losses,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                        hint: 'Losses', icon: Icons.thumb_down_rounded)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: points,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration:
                        fieldDecor(hint: 'Points', icon: Icons.star_rounded)),
              ),
            ]),
            const SizedBox(height: 24),
            GradButton(
              label: existing == null ? 'ADD' : 'SAVE',
              width: double.infinity,
              onTap: () {
                setState(() {
                  if (existing != null) {
                    existing.teamName = name.text;
                    existing.played = int.tryParse(played.text) ?? 0;
                    existing.wins = int.tryParse(wins.text) ?? 0;
                    existing.losses = int.tryParse(losses.text) ?? 0;
                    existing.points = int.tryParse(points.text) ?? 0;
                  } else {
                    widget.tour.standings.add(StandingEntry(
                      id: DateTime.now().toString(),
                      teamName: name.text,
                      played: int.tryParse(played.text) ?? 0,
                      wins: int.tryParse(wins.text) ?? 0,
                      losses: int.tryParse(losses.text) ?? 0,
                      points: int.tryParse(points.text) ?? 0,
                    ));
                  }
                  _sort();
                });
                widget.onUpdate();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStanding(StandingEntry s) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Remove Standing',
      message: 'Remove "${s.teamName}" from standings?',
    );
    if (ok) {
      setState(() => widget.tour.standings.remove(s));
      widget.onUpdate();
    }
  }
}

// ============================================================
// 12. APPROVALS TAB
// ============================================================

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView> {
  GameCtx? _selGame;
  Tournament? _selTour;

  @override
  Widget build(BuildContext context) {
    if (_selGame == null) return _gameLevel();
    if (_selTour == null) return _tourLevel();
    return _teamLevel();
  }

  Widget _gameLevel() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SectionHdr(title: 'SELECT GAME'),
        ),
        ...GameCtx.values.map((g) {
          final count = DB.tournaments.where((t) => t.game == g).length;
          return GestureDetector(
            onTap: () => setState(() => _selGame = g),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: cardDecor(),
              child: Row(children: [
                Text(g.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name,
                            style: AT.subheading.copyWith(fontSize: 15)),
                        Text('$count tournaments', style: AT.caption),
                      ]),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AC.cyan, size: 20),
              ]),
            ),
          );
        }),
      ],
    );
  }

  Widget _tourLevel() {
    final list = DB.tournaments.where((t) => t.game == _selGame).toList();
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AC.border)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _selGame = null),
            child:
                const Icon(Icons.arrow_back_rounded, color: AC.cyan, size: 22),
          ),
          const SizedBox(width: 12),
          Text('${_selGame!.emoji}  ${_selGame!.name}', style: AT.subheading),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (_, idx) {
            final t = list[idx];
            final pending = t.registrants
                .where((r) => r.state == ApprovalState.pending)
                .length;
            return GestureDetector(
              onTap: () => setState(() => _selTour = t),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: cardDecor(),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: AT.subheading.copyWith(fontSize: 14),
                              overflow: TextOverflow.ellipsis),
                          Text('${t.registrants.length} teams applied',
                              style: AT.caption),
                        ]),
                  ),
                  if (pending > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AC.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$pending pending',
                          style:
                              AT.label.copyWith(color: AC.gold, fontSize: 10)),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: AC.cyan, size: 18),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _teamLevel() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AC.border)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _selTour = null),
            child:
                const Icon(Icons.arrow_back_rounded, color: AC.cyan, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_selTour!.title,
                style: AT.subheading.copyWith(fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
      Expanded(
        child: _selTour!.registrants.isEmpty
            ? const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No Registrations',
                subtitle: 'No teams have registered yet')
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _selTour!.registrants.length,
                itemBuilder: (context, idx) {
                  final team = _selTour!.registrants[idx];
                  final stateColor = switch (team.state) {
                    ApprovalState.approved => AC.green,
                    ApprovalState.rejected => AC.red,
                    ApprovalState.pending => AC.gold,
                  };
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: cardDecor(border: stateColor.withOpacity(0.3)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(team.teamName,
                                        style: AT.subheading
                                            .copyWith(fontSize: 15)),
                                    Text('Region: ${team.region}',
                                        style: AT.caption),
                                  ]),
                            ),
                            StatusBadge(
                                label: team.state.name.toUpperCase(),
                                color: stateColor),
                          ]),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            children: team.roster
                                .map((p) => Chip(
                                      label: Text(p,
                                          style: AT.caption
                                              .copyWith(fontSize: 11)),
                                      backgroundColor: AC.bg3,
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlineBtn(
                                label: 'Reject',
                                color: AC.red,
                                onTap: () => setState(
                                    () => team.state = ApprovalState.rejected),
                              ),
                              const SizedBox(width: 10),
                              GradButton(
                                label: 'Approve',
                                icon: Icons.check_rounded,
                                onTap: () => setState(
                                    () => team.state = ApprovalState.approved),
                              ),
                            ],
                          ),
                        ]),
                  );
                },
              ),
      ),
    ]);
  }
}

// ============================================================
// 13. USERS TAB
// ============================================================

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final list = DB.users
        .where((u) =>
            _search.isEmpty ||
            u.name.toLowerCase().contains(_search.toLowerCase()) ||
            u.email.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            style: const TextStyle(color: AC.textPrimary),
            onChanged: (v) => setState(() => _search = v),
            decoration:
                fieldDecor(hint: 'Search users...', icon: Icons.search_rounded),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.person_outline_rounded,
                  title: 'No Users Found',
                  subtitle: 'Try a different search')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final user = list[idx];
                    final isActive = user.status == UserStatus.active;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: cardDecor(
                          border:
                              isActive ? AC.border : AC.red.withOpacity(0.3)),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isActive
                              ? AC.cyan.withOpacity(0.15)
                              : AC.red.withOpacity(0.1),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: isActive ? AC.cyan : AC.red,
                                fontWeight: FontWeight.w800,
                                fontSize: 17),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AT.subheading
                                      .copyWith(fontSize: 14)
                                      .copyWith(
                                          decoration: !isActive
                                              ? TextDecoration.lineThrough
                                              : null),
                                ),
                                Text(user.email, style: AT.caption),
                              ]),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AC.textSecondary, size: 20),
                          color: AC.bg3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) async {
                            if (val == 'toggle') {
                              setState(() => user.status = isActive
                                  ? UserStatus.suspended
                                  : UserStatus.active);
                            } else if (val == 'delete') {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Delete User',
                                message:
                                    'Permanently delete "${user.name}"? This cannot be undone.',
                              );
                              if (ok) {
                                setState(() => DB.users.remove(user));
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'toggle',
                                child: Row(children: [
                                  Icon(
                                      isActive
                                          ? Icons.block_rounded
                                          : Icons.check_circle_outline,
                                      color: isActive ? AC.gold : AC.green,
                                      size: 15),
                                  const SizedBox(width: 10),
                                  Text(isActive
                                      ? 'Suspend User'
                                      : 'Reactivate User'),
                                ])),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      color: AC.red, size: 15),
                                  SizedBox(width: 10),
                                  Text('Delete User',
                                      style: TextStyle(color: AC.red)),
                                ])),
                          ],
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

// ============================================================
// 14. BROADCAST TAB
// ============================================================

class AdminBroadcastView extends StatefulWidget {
  const AdminBroadcastView({super.key});

  @override
  State<AdminBroadcastView> createState() => _AdminBroadcastViewState();
}

class _AdminBroadcastViewState extends State<AdminBroadcastView> {
  bool _toAll = true;
  String? _dropdownEmail;
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Targeting
          SectionHdr(title: 'TARGETING'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecor(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AC.bg3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  _ToggleChip(
                    label: 'All Users',
                    isActive: _toAll,
                    onTap: () => setState(() => _toAll = true),
                  ),
                  _ToggleChip(
                    label: 'Specific User',
                    isActive: !_toAll,
                    onTap: () => setState(() => _toAll = false),
                  ),
                ]),
              ),
              if (!_toAll) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _dropdownEmail,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                      hint: 'Select user', icon: Icons.person_rounded),
                  items: DB.users
                      .map((u) => DropdownMenuItem(
                          value: u.email,
                          child: Text('${u.name} (${u.email})',
                              overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _dropdownEmail = v;
                    if (v != null) _emailCtrl.text = v;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                      hint: 'Or type email manually...',
                      icon: Icons.alternate_email_rounded),
                  onChanged: (val) {
                    if (_dropdownEmail != val) {
                      setState(() => _dropdownEmail = null);
                    }
                  },
                ),
              ],
            ]),
          ),
          const SizedBox(height: 20),

          // Message
          SectionHdr(title: 'MESSAGE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecor(),
            child: TextField(
              controller: _msgCtrl,
              maxLines: 5,
              style: const TextStyle(color: AC.textPrimary),
              decoration: fieldDecor(
                  hint: 'Type your notification message...',
                  icon: Icons.message_rounded),
            ),
          ),
          const SizedBox(height: 24),

          GradButton(
            label: 'SEND NOTIFICATION',
            width: double.infinity,
            icon: Icons.send_rounded,
            onTap: () {
              if (_msgCtrl.text.trim().isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_toAll
                    ? 'Sent to all users'
                    : 'Sent to ${_emailCtrl.text}'),
                backgroundColor: AC.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
              _msgCtrl.clear();
            },
          ),
        ]),
      ),
    );
  }
}
