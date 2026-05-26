import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common/widgets.dart';
import 'player_detail_screen.dart';

// ─── Team Detail Screen ───────────────────────────────────────────────────────
class TeamDetailScreen extends StatefulWidget {
  final TeamModel team;
  // ── FIX: Added isViewOnly flag, defaulting to true to protect other teams ──
  final bool isViewOnly;

  const TeamDetailScreen({
    super.key,
    required this.team,
    this.isViewOnly = true, // Defaults to view-only mode for tournament screen
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late TeamModel _team;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) HapticFeedback.selectionClick();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTeamChanged(TeamModel updated) {
    setState(() => _team = updated);
  }

  // ── FIX 1: Use canPop + onPopInvokedWithResult to avoid double-pop ──
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _team);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg0,
        body: Stack(
          children: [
            Positioned(
              top: 40,
              right: -60,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withOpacity(0.03),
                  ),
                ),
              ),
            ),
            // ── FIX 2: Use DefaultTabController-aware NestedScrollView
            //    and wrap body in a SizedBox.expand so the TabBarView
            //    fills the remaining space properly without overlapping
            //    the pinned header/tab bar.
            NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // ── SLIVER 1: Hero only — no tab bar inside ──────────────
                // expandedHeight = toolbar(56) + safeAreaTop(~44) +
                //   logo row(76) + gaps(32) + badges+location(~60) +
                //   stat cards(~90) + bottom padding(24) ≈ 382
                // We use 390 for a little extra breathing room.
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  stretch: true,
                  // toolbarHeight default is 56 — keep it so back button sits right
                  backgroundColor: AppColors.bg0.withOpacity(0.9),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.textPrimary),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context, _team);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    collapseMode: CollapseMode.pin,
                    background: _TeamHero(team: _team),
                  ),
                  // NO bottom: here — tab bar is its own sliver below
                ),
                // ── SLIVER 2: Tab bar — pinned separately ────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.cyan,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 2,
                      labelColor: AppColors.cyan,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: AppText.label.copyWith(
                          fontWeight: FontWeight.bold, letterSpacing: 1),
                      unselectedLabelStyle: AppText.label.copyWith(
                          fontWeight: FontWeight.normal, letterSpacing: 1),
                      tabs: const [
                        Tab(text: 'ROSTER'),
                        Tab(text: 'PROFILE'),
                        Tab(text: 'MATCHES'),
                      ],
                    ),
                  ),
                ),
              ],
              body: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _RosterTab(
                      team: _team,
                      onTeamChanged: _onTeamChanged,
                      isViewOnly: widget.isViewOnly, // ── Passed Flag
                    ),
                    _InfoTab(
                      team: _team,
                      onTeamChanged: _onTeamChanged,
                      isViewOnly: widget.isViewOnly, // ── Passed Flag
                    ),
                    _MatchesTab(team: _team),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky Tab Bar Delegate ──────────────────────────────────────────────────
// Wraps a TabBar in a SliverPersistentHeader so it pins independently
// from the SliverAppBar — this is the only reliable way to prevent
// the tab bar from overlapping the hero content.
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg0.withOpacity(0.95),
        border:
            const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

// ─── Team Header Hero ─────────────────────────────────────────────────────────
class _TeamHero extends StatelessWidget {
  final TeamModel team;
  const _TeamHero({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg2.withOpacity(0.5), AppColors.bg0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _WavePainter())),
          Positioned(
            right: -10,
            top: 50,
            child: Opacity(
              opacity: 0.02,
              child: Text(
                team.name.split(' ').first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 85,
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.bg3.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.cyan.withOpacity(0.4),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.cyan.withOpacity(0.12),
                                blurRadius: 20)
                          ],
                        ),
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.gradientCyan.createShader(bounds),
                            child: Text(
                              team.name.length >= 2
                                  ? team.name.substring(0, 2).toUpperCase()
                                  : team.name.toUpperCase(),
                              style: AppText.displaySm.copyWith(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: AppText.heading.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                GameBadge(game: team.game, small: true),
                                const SizedBox(width: 8),
                                _TeamStatusBadge(status: team.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  team.country ?? 'Global Region',
                                  style: AppText.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: StatCard(
                              label: 'Wins',
                              value: '${team.wins}',
                              valueColor: AppColors.green)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: StatCard(
                              label: 'Losses',
                              value: '${team.losses}',
                              valueColor: AppColors.red)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Personnel',
                          value:
                              '${team.players.where((p) => p.type == PlayerType.main || p.type == PlayerType.substitute).length}',
                          valueColor: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0, 110 + i * 35.0);
      for (double x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(x + 25, 85 + i * 35.0, x + 50, 110 + i * 35.0);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Roster Tab ───────────────────────────────────────────────────────────────
class _RosterTab extends StatefulWidget {
  final TeamModel team;
  final ValueChanged<TeamModel> onTeamChanged;
  final bool isViewOnly; // ── Passed Flag

  const _RosterTab({
    required this.team,
    required this.onTeamChanged,
    required this.isViewOnly,
  });

  @override
  State<_RosterTab> createState() => _RosterTabState();
}

class _RosterTabState extends State<_RosterTab> {
  late List<PlayerModel> _players;

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.team.players);
  }

  void _notifyChange() {
    widget.onTeamChanged(widget.team.copyWith(players: _players));
  }

  void _deletePlayer(PlayerModel player) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.red.withOpacity(0.4)),
        ),
        title: Text('REMOVE PLAYER',
            style: AppText.heading.copyWith(color: AppColors.red)),
        content: Text(
          'Remove ${player.ign} from the roster? This action cannot be undone.',
          style: AppText.body.copyWith(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppText.label.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _players.remove(player));
              _notifyChange();
            },
            child: Text('REMOVE',
                style: AppText.label.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _addPlayer(PlayerType defaultType) async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlayerSheet(
        game: widget.team.game,
        isCustomGame: false,
        customGameName: '',
        playerIndex: _players.length,
        defaultType: defaultType,
      ),
    );
    if (result != null) {
      final newPlayer = PlayerModel(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        ign: result['ign'] as String,
        type: result['type'] as PlayerType,
        fullName: result['fullName'] as String?,
        role: result['role'] as String?,
        nationality: result['nationality'] as String?,
        gameUID: result['gameUID'] as String?,
        idType: result['idType'] as String?,
        dob: result['dob'] as String?,
        jerseyNumber: (result['jerseyNumber'] as String?)?.isNotEmpty == true
            ? int.tryParse(result['jerseyNumber'] as String)
            : null,
      );
      setState(() => _players.add(newPlayer));
      _notifyChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainLineup =
        _players.where((p) => p.type == PlayerType.main).toList();
    final substitutes =
        _players.where((p) => p.type == PlayerType.substitute).toList();
    final coaches = _players.where((p) => p.type == PlayerType.coach).toList();
    final assistants =
        _players.where((p) => p.type == PlayerType.assistantCoach).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        _buildCategoryHeader(
          'MAIN SQUAD',
          mainLineup.length,
          AppColors.cyan,
          onAdd: () => _addPlayer(PlayerType.main),
          isViewOnly: widget.isViewOnly, // ── Conditionally hide add buttons
        ),
        const SizedBox(height: 12),
        if (mainLineup.isEmpty)
          _EmptySection(label: 'No main players yet')
        else
          ...mainLineup.map((p) => _PlayerCard(
                player: p,
                accentColor: AppColors.cyan,
                onDelete: () => _deletePlayer(p),
                isViewOnly: widget.isViewOnly,
              )),
        const SizedBox(height: 28),
        _buildCategoryHeader(
          'SUBSTITUTES',
          substitutes.length,
          AppColors.gold,
          onAdd: () => _addPlayer(PlayerType.substitute),
          isViewOnly: widget.isViewOnly,
        ),
        const SizedBox(height: 12),
        if (substitutes.isEmpty)
          _EmptySection(label: 'No substitutes yet')
        else
          ...substitutes.map((p) => _PlayerCard(
                player: p,
                accentColor: AppColors.gold,
                onDelete: () => _deletePlayer(p),
                isViewOnly: widget.isViewOnly,
              )),
        const SizedBox(height: 28),
        _buildCategoryHeader(
          'COACHES',
          coaches.length,
          AppColors.purple,
          onAdd: () => _addPlayer(PlayerType.coach),
          isViewOnly: widget.isViewOnly,
        ),
        const SizedBox(height: 12),
        if (coaches.isEmpty)
          _EmptySection(label: 'No coaches yet')
        else
          ...coaches.map((p) => _PlayerCard(
                player: p,
                accentColor: AppColors.purple,
                onDelete: () => _deletePlayer(p),
                isViewOnly: widget.isViewOnly,
              )),
        const SizedBox(height: 28),
        _buildCategoryHeader(
          'ASSISTANT COACHES',
          assistants.length,
          AppColors.magenta,
          onAdd: () => _addPlayer(PlayerType.assistantCoach),
          isViewOnly: widget.isViewOnly,
        ),
        const SizedBox(height: 12),
        if (assistants.isEmpty)
          _EmptySection(label: 'No assistant coaches yet')
        else
          ...assistants.map((p) => _PlayerCard(
                player: p,
                accentColor: AppColors.magenta,
                onDelete: () => _deletePlayer(p),
                isViewOnly: widget.isViewOnly,
              )),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategoryHeader(
    String title,
    int count,
    Color color, {
    required VoidCallback onAdd,
    required bool isViewOnly,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: AppText.label.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6)),
          child: Text(
            '$count',
            style: AppText.label.copyWith(
                color: color, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        if (!isViewOnly) // ── Only show ADD button if they are managing
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text('ADD',
                      style:
                          AppText.label.copyWith(color: color, fontSize: 10)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String label;
  const _EmptySection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bg1.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined,
              size: 16, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(label,
              style: AppText.caption
                  .copyWith(color: AppColors.textMuted.withOpacity(0.6))),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final Color accentColor;
  final VoidCallback onDelete;
  final bool isViewOnly; // ── Flag for deleting

  const _PlayerCard({
    required this.player,
    required this.accentColor,
    required this.onDelete,
    required this.isViewOnly,
  });

  @override
  Widget build(BuildContext context) {
    final isMainSquad = player.type == PlayerType.main;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: isMainSquad
            ? AppDecorations.glowCard(
                glowColor: AppColors.cyan.withOpacity(0.6), radius: 18)
            : AppDecorations.glassCard(radius: 18),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PlayerDetailScreen(player: player)),
              );
            },
            leading: PlayerAvatar(player: player, size: 48),
            title: Row(
              children: [
                Text(
                  player.ign,
                  style: AppText.bodyMd.copyWith(
                      color: accentColor, fontWeight: FontWeight.bold),
                ),
                if (player.jerseyNumber != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      '#${player.jerseyNumber}',
                      style: AppText.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(player.fullName ?? 'Identity Redacted',
                    style: AppText.body.copyWith(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: accentColor.withOpacity(0.25)),
                      ),
                      child: Text(
                        (player.role ?? 'OPERATIVE').toUpperCase(),
                        style: AppText.label.copyWith(
                            color: accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      player.nationality ?? 'Global',
                      style:
                          AppText.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.type.label.toUpperCase(),
                      style: AppText.label
                          .copyWith(color: AppColors.textMuted, fontSize: 9),
                    ),
                  ],
                ),
                if (!isViewOnly) ...[
                  // ── Only show delete button if they are managing
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.red, size: 16),
                    ),
                  ),
                ],
              ],
            ),
          ), // closes Material
        ), // closes Container
      ), // closes Padding
    );
  }
}

// ─── Profile / Info Tab (Conditionally Editable) ────────────────────────────
class _InfoTab extends StatefulWidget {
  final TeamModel team;
  final ValueChanged<TeamModel> onTeamChanged;
  final bool isViewOnly; // ── Passed Flag

  const _InfoTab({
    required this.team,
    required this.onTeamChanged,
    required this.isViewOnly,
  });

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  bool _editing = false;

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _description;
  late final TextEditingController _social;
  late final TextEditingController _country;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.team.name);
    _email = TextEditingController(text: widget.team.contactEmail ?? '');
    _description = TextEditingController(text: widget.team.description ?? '');
    _social = TextEditingController(text: widget.team.socialLink ?? '');
    _country = TextEditingController(text: widget.team.country ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _description.dispose();
    _social.dispose();
    _country.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.team.copyWith(
      name: _name.text.trim().isNotEmpty ? _name.text.trim() : widget.team.name,
      contactEmail: _email.text.trim(),
      description: _description.text.trim(),
      socialLink: _social.text.trim(),
      country: _country.text.trim().isNotEmpty
          ? _country.text.trim()
          : widget.team.country,
    );
    widget.onTeamChanged(updated);
    setState(() => _editing = false);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('TEAM PROFILE', style: _sectionStyle),
              if (!widget.isViewOnly) ...[
                // ── Only show EDIT and CANCEL controls if managing
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (_editing) {
                      _save();
                    } else {
                      setState(() => _editing = true);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _editing
                          ? AppColors.green.withOpacity(0.1)
                          : AppColors.cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _editing
                              ? AppColors.green.withOpacity(0.4)
                              : AppColors.cyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _editing ? Icons.check_rounded : Icons.edit_rounded,
                          size: 14,
                          color: _editing ? AppColors.green : AppColors.cyan,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _editing ? 'SAVE' : 'EDIT',
                          style: AppText.label.copyWith(
                              color:
                                  _editing ? AppColors.green : AppColors.cyan),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_editing) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _name.text = widget.team.name;
                      _email.text = widget.team.contactEmail ?? '';
                      _description.text = widget.team.description ?? '';
                      _social.text = widget.team.socialLink ?? '';
                      _country.text = widget.team.country ?? '';
                      setState(() => _editing = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close_rounded,
                              size: 14, color: AppColors.red),
                          const SizedBox(width: 6),
                          Text('CANCEL',
                              style:
                                  AppText.label.copyWith(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: AppDecorations.glassCard(radius: 20),
            child: Column(
              children: [
                _editing
                    ? _EditableField(
                        icon: Icons.shield_rounded,
                        label: 'Team Name',
                        controller: _name,
                      )
                    : _StaticRow(
                        icon: Icons.shield_rounded,
                        label: 'Designation',
                        value: team.name),
                _buildDivider(),
                _StaticRow(
                    icon: Icons.sports_esports_rounded,
                    label: 'Discipline',
                    value: '${team.game.emoji} ${team.game.label}'),
                _buildDivider(),
                _editing
                    ? _EditableField(
                        icon: Icons.location_on_rounded,
                        label: 'Region',
                        controller: _country,
                      )
                    : _StaticRow(
                        icon: Icons.location_on_rounded,
                        label: 'Operating Hub',
                        value: team.country ?? 'Global'),
                _buildDivider(),
                _editing
                    ? _EditableField(
                        icon: Icons.mail_outline_rounded,
                        label: 'Contact Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      )
                    : _StaticRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Secure Comms',
                        value: team.contactEmail ?? '—'),
                _buildDivider(),
                _editing
                    ? _EditableField(
                        icon: Icons.link_rounded,
                        label: 'Social Link',
                        controller: _social,
                      )
                    : _StaticRow(
                        icon: Icons.link_rounded,
                        label: 'Data Feed',
                        value: team.socialLink?.isNotEmpty == true
                            ? team.socialLink!
                            : '—'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('TEAM BIOGRAPHY', style: _sectionStyle),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.glassCard(radius: 20),
            child: _editing
                ? TextField(
                    controller: _description,
                    maxLines: 5,
                    style:
                        AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe your team...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle:
                          AppText.body.copyWith(color: AppColors.textMuted),
                    ),
                  )
                : Text(
                    team.description?.isNotEmpty == true
                        ? team.description!
                        : 'No biography added yet.',
                    style: AppText.body
                        .copyWith(height: 1.6, color: AppColors.textPrimary),
                  ),
          ),
          const SizedBox(height: 28),
          Text('COMPETITIVE RECORD', style: _sectionStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                      label: 'Wins',
                      value: '${team.wins}',
                      valueColor: AppColors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                      label: 'Losses',
                      value: '${team.losses}',
                      valueColor: AppColors.red)),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Win Rate',
                  value: team.wins + team.losses > 0
                      ? '${((team.wins / (team.wins + team.losses)) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  valueColor: AppColors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  TextStyle get _sectionStyle => AppText.label.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      );

  Widget _buildDivider() => Divider(
      color: AppColors.border.withOpacity(0.4), height: 1, thickness: 1);
}

class _StaticRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _StaticRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.cyan),
          const SizedBox(width: 14),
          Text(label,
              style: AppText.body.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _EditableField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppText.caption.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.cyan, size: 18),
          filled: true,
          fillColor: AppColors.bg3.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Matches Tab ──────────────────────────────────────────────────────────────
class _MatchesTab extends StatelessWidget {
  final TeamModel team;
  const _MatchesTab({required this.team});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.sports_esports_rounded,
      title: 'NO RECORDED ENGAGEMENTS',
      subtitle:
          'This squad has no registered matches in the local ledger history.',
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _TeamStatusBadge extends StatelessWidget {
  final TeamStatus status;
  const _TeamStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final String labelText;
    switch (status) {
      case TeamStatus.approved:
        badgeColor = AppColors.green;
        labelText = '✓ SECURED';
        break;
      case TeamStatus.pending:
        badgeColor = AppColors.gold;
        labelText = '⏳ PENDING';
        break;
      case TeamStatus.rejected:
      default:
        badgeColor = AppColors.red;
        labelText = '✗ DENIED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(labelText,
          style: AppText.label.copyWith(
              color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Add Player Sheet ─────────────────────────────────────────────────────────
class _AddPlayerSheet extends StatefulWidget {
  final GameTitle game;
  final bool isCustomGame;
  final String customGameName;
  final int playerIndex;
  final PlayerType defaultType;

  const _AddPlayerSheet({
    required this.game,
    required this.isCustomGame,
    required this.customGameName,
    required this.playerIndex,
    this.defaultType = PlayerType.main,
  });

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _ign = TextEditingController();
  final _gameUID = TextEditingController();
  final _dob = TextEditingController();
  final _roleController = TextEditingController();

  late PlayerType _type;
  String _nationality = 'Cambodian';
  String _jerseyNo = '';
  bool _showRoleSuggestions = false;

  final _roles = {
    GameTitle.mlbb: [
      'Exp Lane',
      'Gold Lane',
      'Mid Lane',
      'Jungle',
      'Roam',
      'Flex'
    ],
    GameTitle.pubg: ['Fragger', 'IGL', 'Support', 'Sniper'],
    GameTitle.freeFire: ['Rusher', 'Sniper', 'Support', 'IGL'],
    GameTitle.valorant: [
      'Duelist',
      'Controller',
      'Initiator',
      'Sentinel',
      'IGL'
    ],
  };
  final _genericRoles = [
    'IGL',
    'Fragger',
    'Support',
    'Sniper',
    'Flex',
    'Coach',
    'Analyst'
  ];

  List<String> get _availableRoles {
    if (widget.isCustomGame) return _genericRoles;
    return _roles[widget.game] ?? _genericRoles;
  }

  List<String> get _filteredRoles {
    final query = _roleController.text.toLowerCase();
    if (query.isEmpty) return _availableRoles;
    return _availableRoles
        .where((r) => r.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _type = widget.defaultType;
    _roleController.text = _availableRoles.first;
    _roleController.addListener(() => setState(() {}));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.pop(context, {
      'fullName': _fullName.text,
      'ign': _ign.text,
      'role': _roleController.text.isNotEmpty
          ? _roleController.text
          : _availableRoles.first,
      'type': _type,
      'nationality': _nationality,
      'idType': 'National ID',
      'dob': _dob.text,
      'gameUID': _gameUID.text,
      'jerseyNumber': _jerseyNo,
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _ign.dispose();
    _gameUID.dispose();
    _dob.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: AppText.label.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border:
            Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text('ADD PERSONNEL',
                    style: AppText.heading.copyWith(letterSpacing: 1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('CLASSIFICATION *'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: PlayerType.values.map((t) {
                        final Color c = t == PlayerType.main
                            ? AppColors.cyan
                            : t == PlayerType.substitute
                                ? AppColors.gold
                                : AppColors.purple;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _type = t;
                              if (t != PlayerType.main &&
                                  t != PlayerType.substitute) {
                                _roleController.text = t.label;
                              } else {
                                _roleController.text = _availableRoles.first;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _type == t
                                  ? c.withOpacity(0.15)
                                  : AppColors.bg3.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _type == t ? c : AppColors.border),
                            ),
                            child: Text(t.label.toUpperCase(),
                                style: AppText.label.copyWith(
                                    color: _type == t
                                        ? c
                                        : AppColors.textSecondary)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _buildLabel('LEGAL NAME *'),
                    TextFormField(
                      controller: _fullName,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v!.isEmpty ? 'Legal name required' : null,
                      decoration: const InputDecoration(
                        hintText: 'Match government ID',
                        prefixIcon: Icon(Icons.badge_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('IN-GAME ALIAS *'),
                    TextFormField(
                      controller: _ign,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) => v!.isEmpty ? 'IGN is required' : null,
                      decoration: const InputDecoration(
                        hintText: 'e.g. NX.KHEMARA',
                        prefixIcon: Icon(Icons.sports_esports_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_type == PlayerType.main ||
                        _type == PlayerType.substitute) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('ROLE *'),
                                TextFormField(
                                  controller: _roleController,
                                  style: AppText.bodyMd
                                      .copyWith(color: AppColors.textPrimary),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Role required'
                                      : null,
                                  onTap: () => setState(
                                      () => _showRoleSuggestions = true),
                                  onChanged: (_) => setState(
                                      () => _showRoleSuggestions = true),
                                  decoration: InputDecoration(
                                    hintText: 'Pick or type role...',
                                    prefixIcon: const Icon(
                                        Icons.person_pin_circle_rounded,
                                        color: AppColors.textMuted,
                                        size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showRoleSuggestions
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _showRoleSuggestions =
                                              !_showRoleSuggestions),
                                    ),
                                  ),
                                ),
                                if (_showRoleSuggestions &&
                                    _filteredRoles.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bg2,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.border
                                              .withOpacity(0.6)),
                                    ),
                                    child: Column(
                                      children: _filteredRoles.map((r) {
                                        final isSelected =
                                            _roleController.text == r;
                                        return GestureDetector(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _roleController.text = r;
                                              _showRoleSuggestions = false;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.cyan
                                                      .withOpacity(0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(r,
                                                style: AppText.bodyMd.copyWith(
                                                  color: isSelected
                                                      ? AppColors.cyan
                                                      : AppColors.textPrimary,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                )),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('JERSEY'),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  style: AppText.bodyMd
                                      .copyWith(color: AppColors.textPrimary),
                                  onChanged: (v) => _jerseyNo = v,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 7',
                                    prefixIcon: Icon(Icons.numbers_rounded,
                                        color: AppColors.textMuted, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildLabel('PLATFORM UID *'),
                    TextFormField(
                      controller: _gameUID,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) => v!.isEmpty ? 'UID required' : null,
                      decoration: const InputDecoration(
                        hintText: 'Exact game UID',
                        prefixIcon: Icon(Icons.tag_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('NATIONALITY *'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 2),
                      decoration: AppDecorations.inputDecoration,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _nationality,
                          isExpanded: true,
                          dropdownColor: AppColors.bg2,
                          style: AppText.bodyMd
                              .copyWith(color: AppColors.textPrimary),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted),
                          items: [
                            'Cambodian',
                            'Thai',
                            'Vietnamese',
                            'Filipino',
                            'Indonesian',
                            'Malaysian'
                          ]
                              .map((n) =>
                                  DropdownMenuItem(value: n, child: Text(n)))
                              .toList(),
                          onChanged: (v) => setState(() => _nationality = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('DATE OF BIRTH *'),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2003),
                          firstDate: DateTime(1980),
                          lastDate: DateTime(2012),
                          builder: (_, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.cyan,
                                surface: AppColors.bg2,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          setState(() => _dob.text =
                              '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}');
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dob,
                          style: AppText.bodyMd
                              .copyWith(color: AppColors.textPrimary),
                          validator: (v) => v!.isEmpty ? 'DOB required' : null,
                          decoration: const InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icon(Icons.cake_rounded,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5))),
            ),
            child: GlowButton(
              label: 'CONFIRM & ADD TO ROSTER',
              icon: Icons.check_circle_outline_rounded,
              width: double.infinity,
              onTap: _save,
            ),
          ),
        ],
      ),
    );
  }
}
