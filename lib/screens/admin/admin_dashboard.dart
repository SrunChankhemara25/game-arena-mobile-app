// ========================================================================
// UNCOMPROMISED MASTER PLATFORM ARCHITECTURE - MOBILE REDESIGN
// INCLUDES: USER FRONTEND, FULL ADMIN CONSOLE, ALL 7 ADMIN MODULES
// ========================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CompleteMatrixApp());
}

class CompleteMatrixApp extends StatelessWidget {
  const CompleteMatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Tournament Suite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.neonCyan,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RootNavigationShell(),
    );
  }
}

// ========================================================================
// 1. DESIGN SYSTEM & TOKENS
// ========================================================================

class AppColors {
  static const Color bgDark = Color(0xFF07090E);
  static const Color bgSurface = Color(0xFF111520);
  static const Color bgCard = Color(0xFF1A2132);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color matrixGreen = Color(0xFF10B981);
  static const Color alertRed = Color(0xFFEF4444);
  static const Color borderLine = Color(0xFF293249);
}

class AppStyles {
  static BoxDecoration mobileGlassCard({double radius = 16, Color? borderCol}) {
    return BoxDecoration(
      color: AppColors.bgSurface.withOpacity(0.9),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderCol ?? AppColors.borderLine, width: 1.2),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5))
      ],
    );
  }

  static InputDecoration inputFieldsStyle(
      {required String label, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.bgCard,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.neonCyan, size: 18)
          : null,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLine)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5)),
    );
  }
}

// ========================================================================
// 2. CORE MODELS & ENUMS
// ========================================================================

enum GameContext {
  mlbb('Mobile Legends', '⚔️'),
  pubg('PUBG Mobile', '🪂'),
  freeFire('Free Fire', '🔥'),
  valorant('Valorant', '🎮');

  final String name;
  final String emoji;
  const GameContext(this.name, this.emoji);
}

enum TourneyStatus { upcoming, open, live, closed }

enum ApprovalState { pending, approved, rejected }

enum MatrixUserStatus { active, suspended }

class AppUser {
  final String id;
  final String name;
  final String email;
  MatrixUserStatus status;

  AppUser(
      {required this.id,
      required this.name,
      required this.email,
      this.status = MatrixUserStatus.active});
}

class TeamRegistration {
  final String id;
  final String teamName;
  final String baseRegion;
  final List<String> roster;
  ApprovalState state;

  TeamRegistration(
      {required this.id,
      required this.teamName,
      required this.baseRegion,
      required this.roster,
      this.state = ApprovalState.pending});
}

class TournamentInstance {
  final String id;
  String title;
  GameContext game;
  TourneyStatus status;
  String prize;
  bool isArchived;
  List<TeamRegistration> registrants;

  TournamentInstance(
      {required this.id,
      required this.title,
      required this.game,
      required this.status,
      required this.prize,
      this.isArchived = false,
      required this.registrants});
}

class MatchNode {
  final String id;
  String teamA;
  String teamB;
  int scoreA;
  int scoreB;
  bool isFinalized;
  String winner;

  MatchNode(
      {required this.id,
      required this.teamA,
      required this.teamB,
      this.scoreA = 0,
      this.scoreB = 0,
      this.isFinalized = false,
      this.winner = ''});
}

class BracketRound {
  final String id;
  String roundName;
  List<MatchNode> matches;

  BracketRound(
      {required this.id, required this.roundName, required this.matches});
}

class ScheduleNode {
  final String id;
  String roundTitle;
  String teamA;
  String teamB;
  String dateTime;

  ScheduleNode(
      {required this.id,
      required this.roundTitle,
      required this.teamA,
      required this.teamB,
      required this.dateTime});
}

class StandingsEntry {
  final String teamName;
  int wins;
  int losses;
  int points;

  StandingsEntry(
      {required this.teamName,
      this.wins = 0,
      this.losses = 0,
      this.points = 0});
}

// ========================================================================
// 3. MASTER IN-MEMORY DATABASE BUFFER
// ========================================================================

class CentralDatabase {
  static List<AppUser> users = [
    AppUser(id: 'u1', name: 'Nova Admin', email: 'admin@matrix.com'),
    AppUser(id: 'u2', name: 'Player One', email: 'p1@esports.gg'),
  ];

  static List<TournamentInstance> tournaments = [
    TournamentInstance(
      id: 't1',
      title: 'MLBB World Championship 2026',
      game: GameContext.mlbb,
      status: TourneyStatus.live,
      prize: '\$100,000',
      registrants: [
        TeamRegistration(
            id: 'r1',
            teamName: 'Evos Legends',
            baseRegion: 'ID',
            roster: ['Oura', 'Wannn', 'Rekt', 'Luminaire', 'Donkey'],
            state: ApprovalState.approved),
        TeamRegistration(
            id: 'r2',
            teamName: 'Blacklist Intl',
            baseRegion: 'PH',
            roster: ['OhMyV33nus', 'Wise', 'OHEB', 'Edward', 'Hadji'],
            state: ApprovalState.pending),
      ],
    ),
    TournamentInstance(
      id: 't2',
      title: 'PUBG Mobile Global Series',
      game: GameContext.pubg,
      status: TourneyStatus.open,
      prize: '\$50,000',
      registrants: [],
    ),
  ];

  static List<ScheduleNode> schedules = [
    ScheduleNode(
        id: 's1',
        roundTitle: 'Group Stage A',
        teamA: 'Evos Legends',
        teamB: 'RRQ Hoshi',
        dateTime: '2026-06-01 14:00'),
  ];

  static List<BracketRound> bracketTree = [
    BracketRound(
      id: 'b1',
      roundName: 'Quarterfinals',
      matches: [
        MatchNode(id: 'm1', teamA: 'Evos Legends', teamB: 'Blacklist Intl'),
        MatchNode(id: 'm2', teamA: 'RRQ Hoshi', teamB: 'Echo PH'),
      ],
    )
  ];

  static List<StandingsEntry> standings = [
    StandingsEntry(teamName: 'Evos Legends', wins: 5, losses: 1, points: 15),
    StandingsEntry(teamName: 'Blacklist Intl', wins: 4, losses: 2, points: 12),
    StandingsEntry(teamName: 'RRQ Hoshi', wins: 2, losses: 4, points: 6),
  ];
}

// ========================================================================
// 4. ROOT NAVIGATION SHELL (USER VS ADMIN)
// ========================================================================

class RootNavigationShell extends StatefulWidget {
  const RootNavigationShell({super.key});

  @override
  State<RootNavigationShell> createState() => _RootNavigationShellState();
}

class _RootNavigationShellState extends State<RootNavigationShell> {
  int _currentIndex = 0;
  final List<Widget> _views = [
    const MobileExploreUserView(),
    const MasterAdminDashboard()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = idx);
        },
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.public_rounded), label: 'USER EXPLORE'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'ADMIN HQ'),
        ],
      ),
    );
  }
}

// ========================================================================
// 5. USER FRONTEND: MOBILE EXPLORE SCREEN
// ========================================================================

class MobileExploreUserView extends StatefulWidget {
  const MobileExploreUserView({super.key});

  @override
  State<MobileExploreUserView> createState() => _MobileExploreUserViewState();
}

class _MobileExploreUserViewState extends State<MobileExploreUserView> {
  GameContext? _activeFilter;

  @override
  Widget build(BuildContext context) {
    final activeTourneys = CentralDatabase.tournaments
        .where((t) =>
            !t.isArchived && (_activeFilter == null || t.game == _activeFilter))
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          Text('MATRIX ARENA',
              style: TextStyle(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Live Tournaments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('ALL GAMES'),
                  selected: _activeFilter == null,
                  selectedColor: AppColors.neonCyan.withOpacity(0.2),
                  onSelected: (_) => setState(() => _activeFilter = null),
                ),
                const SizedBox(width: 8),
                ...GameContext.values.map((g) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${g.emoji} ${g.name}'),
                        selected: _activeFilter == g,
                        selectedColor: AppColors.neonCyan.withOpacity(0.2),
                        onSelected: (_) => setState(() => _activeFilter = g),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...activeTourneys.map((tour) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.mobileGlassCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tour.game.emoji} ${tour.game.name}',
                            style: const TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color:
                                  _getStatusColor(tour.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(tour.status.name.toUpperCase(),
                              style: TextStyle(
                                  color: _getStatusColor(tour.status),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(tour.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Prize Pool: ${tour.prize}',
                        style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tour.registrants.length} Teams Enrolled',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.textMuted, size: 18),
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Color _getStatusColor(TourneyStatus s) {
    switch (s) {
      case TourneyStatus.live:
        return AppColors.alertRed;
      case TourneyStatus.open:
        return AppColors.matrixGreen;
      case TourneyStatus.upcoming:
        return AppColors.neonCyan;
      case TourneyStatus.closed:
        return AppColors.textMuted;
    }
  }
}

// ========================================================================
// 6. MASTER ADMIN DASHBOARD (7 SCROLLABLE TABS)
// ========================================================================

class MasterAdminDashboard extends StatelessWidget {
  const MasterAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          elevation: 0,
          title: const Text('HQ MATRIX CONTROL',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.neonCyan,
            labelColor: AppColors.neonCyan,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'TOURNAMENTS'),
              Tab(text: 'APPROVALS'),
              Tab(text: 'SCHEDULES'),
              Tab(text: 'BRACKETS'),
              Tab(text: 'STANDINGS'),
              Tab(text: 'USERS'),
              Tab(text: 'BROADCAST'),
            ],
          ),
        ),
        body: const TabBarView(
          physics:
              NeverScrollableScrollPhysics(), // Prevent swipe conflict with horizontal bracket
          children: [
            AdminTournamentsView(),
            AdminApprovalsView(),
            AdminSchedulesView(),
            AdminBracketsView(),
            AdminStandingsView(),
            AdminUsersView(),
            AdminBroadcastView(),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 1: TOURNAMENT MANAGEMENT (POST, EDIT, ARCHIVE)
// ------------------------------------------------------------------------

class AdminTournamentsView extends StatefulWidget {
  const AdminTournamentsView({super.key});

  @override
  State<AdminTournamentsView> createState() => _AdminTournamentsViewState();
}

class _AdminTournamentsViewState extends State<AdminTournamentsView> {
  bool _viewArchives = false;

  @override
  Widget build(BuildContext context) {
    final list = CentralDatabase.tournaments
        .where((t) => t.isArchived == _viewArchives)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                    child: ChoiceChip(
                        label: const Center(child: Text('ACTIVE DEPLOYS')),
                        selected: !_viewArchives,
                        onSelected: (_) =>
                            setState(() => _viewArchives = false))),
                const SizedBox(width: 12),
                Expanded(
                    child: ChoiceChip(
                        label: const Center(child: Text('VAULT ARCHIVES')),
                        selected: _viewArchives,
                        onSelected: (_) =>
                            setState(() => _viewArchives = true))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final tour = list[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyles.mobileGlassCard(),
                  child: Row(
                    children: [
                      Text(tour.game.emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tour.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                                '${tour.status.name.toUpperCase()} • ${tour.prize}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AppColors.textSecondary),
                        color: AppColors.bgCard,
                        onSelected: (val) {
                          if (val == 'edit') _showTournamentForm(tour);
                          if (val == 'archive')
                            setState(() => tour.isArchived = !tour.isArchived);
                          if (val == 'delete')
                            setState(
                                () => CentralDatabase.tournaments.remove(tour));
                        },
                        itemBuilder: (_) => [
                          if (!_viewArchives)
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit Config')),
                          PopupMenuItem(
                              value: 'archive',
                              child: Text(_viewArchives
                                  ? 'Restore from Vault'
                                  : 'Send to Archive')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Permanently',
                                  style: TextStyle(color: AppColors.alertRed))),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: !_viewArchives
          ? FloatingActionButton(
              backgroundColor: AppColors.neonCyan,
              child: const Icon(Icons.add, color: AppColors.bgDark),
              onPressed: () => _showTournamentForm(null),
            )
          : null,
    );
  }

  void _showTournamentForm(TournamentInstance? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final prizeCtrl = TextEditingController(text: existing?.prize ?? '');
    GameContext selGame = existing?.game ?? GameContext.mlbb;
    TourneyStatus selStatus = existing?.status ?? TourneyStatus.upcoming;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'CREATE TOURNAMENT' : 'EDIT TOURNAMENT',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // MOCK BANNER/LOGO UPLOAD
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLine)),
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded,
                          color: AppColors.textMuted),
                      SizedBox(height: 4),
                      Text('Tap to upload Banner/Logo',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 10))
                    ]),
              ),
              const SizedBox(height: 16),

              TextField(
                  controller: titleCtrl,
                  decoration:
                      AppStyles.inputFieldsStyle(label: 'Tournament Title')),
              const SizedBox(height: 12),
              TextField(
                  controller: prizeCtrl,
                  decoration: AppStyles.inputFieldsStyle(label: 'Prize Pool')),
              const SizedBox(height: 12),

              DropdownButtonFormField<GameContext>(
                value: selGame,
                dropdownColor: AppColors.bgCard,
                decoration: AppStyles.inputFieldsStyle(label: 'Game Category'),
                items: GameContext.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setModalState(() => selGame = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TourneyStatus>(
                value: selStatus,
                dropdownColor: AppColors.bgCard,
                decoration:
                    AppStyles.inputFieldsStyle(label: 'Operational Status'),
                items: TourneyStatus.values
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setModalState(() => selStatus = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan),
                  onPressed: () {
                    setState(() {
                      if (existing != null) {
                        existing.title = titleCtrl.text;
                        existing.prize = prizeCtrl.text;
                        existing.game = selGame;
                        existing.status = selStatus;
                      } else {
                        CentralDatabase.tournaments.add(TournamentInstance(
                          id: 't_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text,
                          game: selGame,
                          status: selStatus,
                          prize: prizeCtrl.text,
                          registrants: [],
                        ));
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                      existing == null ? 'PUBLISH EVENT' : 'UPDATE CONFIG',
                      style: const TextStyle(
                          color: AppColors.bgDark,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 2: HIERARCHICAL APPROVALS (GAME -> TOURNEY -> TEAM)
// ------------------------------------------------------------------------

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView> {
  GameContext? _selGame;
  TournamentInstance? _selTourney;

  @override
  Widget build(BuildContext context) {
    if (_selGame == null) return _buildGameLevel();
    if (_selTourney == null) return _buildTourneyLevel();
    return _buildTeamLevel();
  }

  Widget _buildGameLevel() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: GameContext.values.map((game) {
        final count =
            CentralDatabase.tournaments.where((t) => t.game == game).length;
        return ListTile(
          onTap: () => setState(() => _selGame = game),
          tileColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderLine)),
          leading: Text(game.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(game.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$count Tournaments',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.neonCyan),
        );
      }).toList(),
    );
  }

  Widget _buildTourneyLevel() {
    final list =
        CentralDatabase.tournaments.where((t) => t.game == _selGame).toList();
    return Column(
      children: [
        ListTile(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
              onPressed: () => setState(() => _selGame = null)),
          title: Text('${_selGame!.name} Tournaments',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppStyles.mobileGlassCard(),
                child: ListTile(
                  onTap: () => setState(() => _selTourney = list[idx]),
                  title: Text(list[idx].title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${list[idx].registrants.length} Teams applied',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.neonCyan),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildTeamLevel() {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
              onPressed: () => setState(() => _selTourney = null)),
          title: Text(_selTourney!.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _selTourney!.registrants.length,
            itemBuilder: (context, idx) {
              final team = _selTourney!.registrants[idx];
              Color sColor = team.state == ApprovalState.approved
                  ? AppColors.matrixGreen
                  : team.state == ApprovalState.rejected
                      ? AppColors.alertRed
                      : AppColors.goldAccent;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.mobileGlassCard(
                    borderCol: sColor.withOpacity(0.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(team.teamName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AppColors.textSecondary),
                          color: AppColors.bgCard,
                          onSelected: (val) {
                            if (val == 'approve')
                              setState(
                                  () => team.state = ApprovalState.approved);
                            if (val == 'reject')
                              setState(
                                  () => team.state = ApprovalState.rejected);
                            if (val == 'pending')
                              setState(
                                  () => team.state = ApprovalState.pending);
                            if (val == 'delete') _confirmDeleteTeam(team);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'approve',
                                child: Text('Approve',
                                    style: TextStyle(
                                        color: AppColors.matrixGreen))),
                            const PopupMenuItem(
                                value: 'reject',
                                child: Text('Reject',
                                    style:
                                        TextStyle(color: AppColors.alertRed))),
                            const PopupMenuItem(
                                value: 'pending',
                                child: Text('Set Pending',
                                    style: TextStyle(
                                        color: AppColors.goldAccent))),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Team',
                                    style:
                                        TextStyle(color: AppColors.alertRed))),
                          ],
                        )
                      ],
                    ),
                    Text('Region: ${team.baseRegion}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: sColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(team.state.name.toUpperCase(),
                            style: TextStyle(
                                color: sColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                    const Divider(color: AppColors.borderLine, height: 24),
                    const Text('ROSTER:',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 6,
                      children: team.roster
                          .map((p) => Chip(
                              label:
                                  Text(p, style: const TextStyle(fontSize: 10)),
                              backgroundColor: AppColors.bgCard,
                              side: BorderSide.none))
                          .toList(),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _confirmDeleteTeam(TeamRegistration team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Confirm Deletion',
            style: TextStyle(color: AppColors.alertRed)),
        content: Text(
            'Are you sure you want to permanently delete "${team.teamName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () {
              setState(() => _selTourney!.registrants.remove(team));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 3: SCHEDULES (DATE/TIME MAPPING)
// ------------------------------------------------------------------------

class AdminSchedulesView extends StatefulWidget {
  const AdminSchedulesView({super.key});

  @override
  State<AdminSchedulesView> createState() => _AdminSchedulesViewState();
}

class _AdminSchedulesViewState extends State<AdminSchedulesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: CentralDatabase.schedules.length,
        itemBuilder: (context, idx) {
          final sch = CentralDatabase.schedules[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.mobileGlassCard(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sch.roundTitle,
                          style: const TextStyle(
                              color: AppColors.goldAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('${sch.teamA} vs ${sch.teamB}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(sch.dateTime,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.alertRed),
                  onPressed: () =>
                      setState(() => CentralDatabase.schedules.removeAt(idx)),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonCyan,
        onPressed: _addSchedule,
        child: const Icon(Icons.add, color: AppColors.bgDark),
      ),
    );
  }

  void _addSchedule() {
    final tCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final dtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('NEW SCHEDULE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
                controller: tCtrl,
                decoration: AppStyles.inputFieldsStyle(label: 'Round/Stage')),
            const SizedBox(height: 10),
            TextField(
                controller: aCtrl,
                decoration: AppStyles.inputFieldsStyle(label: 'Team A')),
            const SizedBox(height: 10),
            TextField(
                controller: bCtrl,
                decoration: AppStyles.inputFieldsStyle(label: 'Team B')),
            const SizedBox(height: 10),
            TextField(
                controller: dtCtrl,
                decoration: AppStyles.inputFieldsStyle(
                    label: 'Date & Time (e.g. 2026-06-01 14:00)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan),
                onPressed: () {
                  setState(() {
                    CentralDatabase.schedules.add(ScheduleNode(
                        id: DateTime.now().toString(),
                        roundTitle: tCtrl.text,
                        teamA: aCtrl.text,
                        teamB: bCtrl.text,
                        dateTime: dtCtrl.text));
                  });
                  Navigator.pop(context);
                },
                child: const Text('ADD TO TIMELINE',
                    style: TextStyle(
                        color: AppColors.bgDark, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 4: DYNAMIC BRACKET TREE (HORIZONTAL SWIPE)
// ------------------------------------------------------------------------

class AdminBracketsView extends StatefulWidget {
  const AdminBracketsView({super.key});

  @override
  State<AdminBracketsView> createState() => _AdminBracketsViewState();
}

class _AdminBracketsViewState extends State<AdminBracketsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(20),
        itemCount: CentralDatabase.bracketTree.length,
        itemBuilder: (context, roundIdx) {
          final round = CentralDatabase.bracketTree[roundIdx];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(round.roundName.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.neonPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    IconButton(
                        icon: const Icon(Icons.delete,
                            color: AppColors.alertRed, size: 18),
                        onPressed: () => setState(() =>
                            CentralDatabase.bracketTree.removeAt(roundIdx))),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: round.matches.length,
                    itemBuilder: (context, matchIdx) {
                      final m = round.matches[matchIdx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: AppStyles.mobileGlassCard(
                            borderCol: m.isFinalized
                                ? AppColors.matrixGreen.withOpacity(0.5)
                                : AppColors.borderLine),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Match ID: ${m.id}',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textMuted)),
                                GestureDetector(
                                    onTap: () => _editMatchScore(m, roundIdx),
                                    child: const Icon(Icons.edit,
                                        size: 16, color: AppColors.neonCyan)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildTeamRow(m.teamA, m.scoreA,
                                m.isFinalized && m.winner == m.teamA),
                            const Divider(
                                color: AppColors.borderLine, height: 16),
                            _buildTeamRow(m.teamB, m.scoreB,
                                m.isFinalized && m.winner == m.teamB),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.neonPurple,
        onPressed: _addBracketRound,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD ROUND',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTeamRow(String name, int score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(name,
                style: TextStyle(
                    fontWeight: isWinner ? FontWeight.w900 : FontWeight.normal,
                    color: isWinner ? AppColors.matrixGreen : Colors.white),
                overflow: TextOverflow.ellipsis)),
        Text('$score',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner
                    ? AppColors.matrixGreen
                    : AppColors.textSecondary)),
      ],
    );
  }

  void _addBracketRound() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Add Round'),
        content: TextField(
            controller: ctrl,
            decoration: AppStyles.inputFieldsStyle(
                label: 'Round Name (e.g. Semifinals)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => CentralDatabase.bracketTree.add(BracketRound(
                      id: DateTime.now().toString(),
                      roundName: ctrl.text,
                      matches: [
                        MatchNode(id: 'm_new', teamA: 'TBD', teamB: 'TBD')
                      ])));
              Navigator.pop(context);
            },
            child:
                const Text('Add', style: TextStyle(color: AppColors.neonCyan)),
          )
        ],
      ),
    );
  }

  void _editMatchScore(MatchNode m, int roundIdx) {
    final sA = TextEditingController(text: m.scoreA.toString());
    final sB = TextEditingController(text: m.scoreB.toString());
    String win = m.teamA;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EDIT MATCH SCORES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                  controller: sA,
                  keyboardType: TextInputType.number,
                  decoration:
                      AppStyles.inputFieldsStyle(label: '${m.teamA} Score')),
              const SizedBox(height: 10),
              TextField(
                  controller: sB,
                  keyboardType: TextInputType.number,
                  decoration:
                      AppStyles.inputFieldsStyle(label: '${m.teamB} Score')),
              const SizedBox(height: 16),
              const Text('SELECT WINNER TO ADVANCE:',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              DropdownButton<String>(
                value: win,
                isExpanded: true,
                dropdownColor: AppColors.bgCard,
                items: [m.teamA, m.teamB]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModalState(() => win = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.matrixGreen),
                  onPressed: () {
                    setState(() {
                      m.scoreA = int.parse(sA.text);
                      m.scoreB = int.parse(sB.text);
                      m.isFinalized = true;
                      m.winner = win;

                      // Auto Advance Logic
                      if (roundIdx + 1 < CentralDatabase.bracketTree.length) {
                        var nextRound =
                            CentralDatabase.bracketTree[roundIdx + 1];
                        if (nextRound.matches.isNotEmpty) {
                          if (nextRound.matches[0].teamA == 'TBD')
                            nextRound.matches[0].teamA = win;
                          else
                            nextRound.matches[0].teamB = win;
                        }
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('SAVE & ADVANCE WINNER',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 5: STANDINGS (AUTO-SORTING LEDGER)
// ------------------------------------------------------------------------

class AdminStandingsView extends StatefulWidget {
  const AdminStandingsView({super.key});

  @override
  State<AdminStandingsView> createState() => _AdminStandingsViewState();
}

class _AdminStandingsViewState extends State<AdminStandingsView> {
  @override
  void initState() {
    super.initState();
    _sortStandings();
  }

  void _sortStandings() {
    CentralDatabase.standings.sort((a, b) => b.points.compareTo(a.points));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: AppStyles.mobileGlassCard(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.borderLine))),
                child: Row(
                  children: const [
                    Expanded(
                        flex: 3,
                        child: Text('TEAM',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('W',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('L',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('PTS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.goldAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('EDIT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              ...CentralDatabase.standings.map((entry) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.borderLine))),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(entry.teamName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 1,
                            child: Text('${entry.wins}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13))),
                        Expanded(
                            flex: 1,
                            child: Text('${entry.losses}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13))),
                        Expanded(
                            flex: 1,
                            child: Text('${entry.points}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13))),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: () => _editStandingsRow(entry),
                                child: const Icon(Icons.edit,
                                    size: 16, color: AppColors.neonCyan))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _editStandingsRow(StandingsEntry entry) {
    final wCtrl = TextEditingController(text: entry.wins.toString());
    final lCtrl = TextEditingController(text: entry.losses.toString());
    final pCtrl = TextEditingController(text: entry.points.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Edit ${entry.teamName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: wCtrl,
                keyboardType: TextInputType.number,
                decoration: AppStyles.inputFieldsStyle(label: 'Wins')),
            const SizedBox(height: 10),
            TextField(
                controller: lCtrl,
                keyboardType: TextInputType.number,
                decoration: AppStyles.inputFieldsStyle(label: 'Losses')),
            const SizedBox(height: 10),
            TextField(
                controller: pCtrl,
                keyboardType: TextInputType.number,
                decoration: AppStyles.inputFieldsStyle(label: 'Points')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                entry.wins = int.parse(wCtrl.text);
                entry.losses = int.parse(lCtrl.text);
                entry.points = int.parse(pCtrl.text);
                _sortStandings(); // Auto order logic
              });
              Navigator.pop(context);
            },
            child: const Text('Save & Sort',
                style: TextStyle(color: AppColors.neonCyan)),
          )
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 6: USERS MATRIX (SUSPEND, ACTIVATE, DELETE)
// ------------------------------------------------------------------------

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: CentralDatabase.users.length,
        itemBuilder: (context, idx) {
          final user = CentralDatabase.users[idx];
          bool isSuspended = user.status == MatrixUserStatus.suspended;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.mobileGlassCard(
                borderCol: isSuspended
                    ? AppColors.alertRed.withOpacity(0.5)
                    : AppColors.borderLine),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: isSuspended
                        ? AppColors.bgCard
                        : AppColors.neonCyan.withOpacity(0.1),
                    child: Icon(Icons.person,
                        color: isSuspended
                            ? AppColors.textMuted
                            : AppColors.neonCyan)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isSuspended
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isSuspended
                                  ? AppColors.textMuted
                                  : Colors.white)),
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  color: AppColors.bgCard,
                  onSelected: (val) {
                    if (val == 'toggle')
                      setState(() => user.status = isSuspended
                          ? MatrixUserStatus.active
                          : MatrixUserStatus.suspended);
                    if (val == 'delete')
                      setState(() => CentralDatabase.users.removeAt(idx));
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'toggle',
                        child: Text(
                            isSuspended ? 'Reactivate User' : 'Suspend User')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Purge User',
                            style: TextStyle(color: AppColors.alertRed))),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------------
// ADMIN TAB 7: ADVANCED BROADCAST NOTIFICATION HUB
// ------------------------------------------------------------------------

class AdminBroadcastView extends StatefulWidget {
  const AdminBroadcastView({super.key});

  @override
  State<AdminBroadcastView> createState() => _AdminBroadcastViewState();
}

class _AdminBroadcastViewState extends State<AdminBroadcastView> {
  bool _sendToAll = true;
  String? _dropdownEmail;
  final _emailTypeController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.mobileGlassCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TARGETING STRATEGY',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: ChoiceChip(
                              label: const Center(child: Text('GLOBAL ALL')),
                              selected: _sendToAll,
                              selectedColor:
                                  AppColors.neonCyan.withOpacity(0.2),
                              onSelected: (_) =>
                                  setState(() => _sendToAll = true))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: ChoiceChip(
                              label:
                                  const Center(child: Text('TARGET SPECIFIC')),
                              selected: !_sendToAll,
                              selectedColor:
                                  AppColors.neonCyan.withOpacity(0.2),
                              onSelected: (_) =>
                                  setState(() => _sendToAll = false))),
                    ],
                  ),
                  if (!_sendToAll) ...[
                    const SizedBox(height: 16),
                    const Text('Select registered user:',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _dropdownEmail,
                      dropdownColor: AppColors.bgCard,
                      decoration: AppStyles.inputFieldsStyle(
                          label: 'Dropdown Selection'),
                      items: CentralDatabase.users
                          .map((u) => DropdownMenuItem(
                              value: u.email, child: Text(u.email)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _dropdownEmail = v;
                        if (v != null) _emailTypeController.text = v;
                      }),
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                            child: Text('OR TYPE MANUAL EMAIL OVERRIDE',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.goldAccent,
                                    fontWeight: FontWeight.bold)))),
                    TextField(
                      controller: _emailTypeController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        if (_dropdownEmail != val)
                          setState(() => _dropdownEmail = null);
                      },
                      decoration: AppStyles.inputFieldsStyle(
                          label: 'Type exact email address...'),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.mobileGlassCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PAYLOAD MESSAGE',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: AppStyles.inputFieldsStyle(
                          label: 'Type notification body...')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (_messageController.text.isEmpty) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: AppColors.matrixGreen,
                    content: Text(
                        'Transmission sent to ${_sendToAll ? "ALL USERS" : _emailTypeController.text}')));
                _messageController.clear();
              },
              icon: const Icon(Icons.send_rounded, color: AppColors.bgDark),
              label: const Text('DISPATCH NOTIFICATION',
                  style: TextStyle(
                      color: AppColors.bgDark, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
