import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../../services/media_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common/widgets.dart';
import 'team_detail_screen.dart';

// ─── My Team Screen ───────────────────────────────────────────────────────────
class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen>
    with SingleTickerProviderStateMixin {
  TeamModel? _myTeam;
  String? _userEmail;
  bool _loading = true;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceController.forward();
    _loadMyTeam();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _createTeam() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push<TeamModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTeamScreen(
          ownerEmail: _userEmail,
          initialContactEmail: _userEmail,
        ),
      ),
    );
    if (result != null) {
      await _persistTeam(result);
      _entranceController.forward(from: 0.0);
    }
  }

  void _deleteSquad() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.red.withOpacity(0.4)),
        ),
        title: Text(
          'DISBAND SQUAD',
          style:
              AppText.heading.copyWith(color: AppColors.red, letterSpacing: 1),
        ),
        content: Text(
          'This will permanently delete your squad and all roster data. This action cannot be undone.',
          style: AppText.body.copyWith(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppText.label.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final currentTeam = _myTeam;
              setState(() => _myTeam = null);
              if (currentTeam != null) {
                await BackendService.instance.deleteTeam(currentTeam.id);
              }
              if (_userEmail != null) {
                final user =
                    await BackendService.instance.getUserProfile(_userEmail!);
                if (user != null) {
                  await BackendService.instance
                      .saveUserProfile(user.copyWith(teamId: null));
                }
              }
              _entranceController.forward(from: 0.0);
            },
            child: Text('DISBAND',
                style: AppText.label.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _editTeamName() async {
    if (_myTeam?.registeredTournamentIds.isNotEmpty == true) {
      _showLockedTeamSnack();
      return;
    }
    final ctrl = TextEditingController(text: _myTeam?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text('EDIT TEAM NAME',
            style: AppText.heading.copyWith(letterSpacing: 1)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Team name...',
            prefixIcon: const Icon(Icons.shield_rounded,
                color: AppColors.textMuted, size: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppText.label.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text('SAVE',
                style: AppText.label.copyWith(color: AppColors.cyan)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _myTeam != null) {
      await _persistTeam(_myTeam!.copyWith(name: result));
    }
  }

  Future<void> _loadMyTeam() async {
    final email = await AuthService().getLoggedInUserEmail();
    TeamModel? team;
    if (email != null) {
      team = await BackendService.instance.getTeamByOwner(email);
    }
    if (!mounted) return;
    setState(() {
      _userEmail = email;
      _myTeam = team;
      _loading = false;
    });
  }

  Future<void> _persistTeam(TeamModel updated) async {
    await BackendService.instance.saveTeam(updated);
    if (_userEmail != null) {
      final user = await BackendService.instance.getUserProfile(_userEmail!);
      if (user != null) {
        await BackendService.instance
            .saveUserProfile(user.copyWith(teamId: updated.id));
      }
    }
    if (!mounted) return;
    setState(() => _myTeam = updated);
  }

  void _showTeamMenu() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border:
              Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text('SQUAD OPTIONS',
                style: AppText.label
                    .copyWith(color: AppColors.textMuted, letterSpacing: 2)),
            const SizedBox(height: 20),
            _MenuTile(
              icon: Icons.edit_rounded,
              label: 'Edit Team Name',
              color: AppColors.cyan,
              onTap: () {
                Navigator.pop(context);
                _editTeamName();
              },
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.add_photo_alternate_rounded,
              label: 'Change Team Logo',
              color: AppColors.purple,
              onTap: () {
                Navigator.pop(context);
                _changeTeamLogo();
              },
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.delete_forever_rounded,
              label: 'Disband Squad',
              color: AppColors.red,
              onTap: () {
                Navigator.pop(context);
                _deleteSquad();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: GlassAppBar(
        title: 'MY ROSTER',
        showBack: false,
        actions: _myTeam != null
            ? [
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textPrimary, size: 22),
                  onPressed: _showTeamMenu,
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.04),
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan),
                  )
                : _myTeam == null
                    ? _NoTeamView(onCreate: _createTeam)
                    : _HasTeamView(
                        team: _myTeam!,
                        onTeamUpdated: (updated) => _persistTeam(updated),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeTeamLogo() async {
    final team = _myTeam;
    if (team == null) return;
    if (team.registeredTournamentIds.isNotEmpty) {
      _showLockedTeamSnack();
      return;
    }
    HapticFeedback.lightImpact();
    final picked =
        await MediaService.pickImage(maxWidth: 640, imageQuality: 76);
    if (picked == null) return;
    await _persistTeam(team.copyWith(logoUrl: picked.dataUrl));
  }

  void _showLockedTeamSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This team is locked after tournament registration. Admin can update approved rosters.',
        ),
      ),
    );
  }
}

// ─── Menu Tile ────────────────────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Text(label,
                style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _NoTeamView extends StatelessWidget {
  final VoidCallback onCreate;
  const _NoTeamView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg2.withOpacity(0.5),
              border:
                  Border.all(color: AppColors.cyan.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.cyan.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 5)
              ],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (b) => AppColors.gradientCyan.createShader(b),
                child: const Icon(Icons.shield_moon_rounded,
                    size: 64, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'NO ROSTER FOUND',
            style: AppText.displaySm
                .copyWith(letterSpacing: 1, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Assemble your squad, register for official tournaments, and climb the global leaderboards.',
            style: AppText.body.copyWith(fontSize: 15, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GlowButton(
            label: 'ESTABLISH NEW TEAM',
            width: double.infinity,
            icon: Icons.add_moderator_rounded,
            onTap: onCreate,
          ),
          const SizedBox(height: 48),
          const SectionHeader(title: 'PLATFORM BENEFITS'),
          const SizedBox(height: 16),
          const _BenefitRow(
              icon: Icons.emoji_events_rounded,
              color: AppColors.gold,
              title: 'Join Official Tournaments',
              sub: 'Gain entry to verified competitive events.'),
          const _BenefitRow(
              icon: Icons.people_alt_rounded,
              color: AppColors.cyan,
              title: 'Roster Management',
              sub: 'Organize players, coaches, and staff seamlessly.'),
          const _BenefitRow(
              icon: Icons.leaderboard_rounded,
              color: AppColors.green,
              title: 'Track Performance',
              sub: 'Automated match history and bracket tracking.'),
          const _BenefitRow(
              icon: Icons.visibility_rounded,
              color: AppColors.purple,
              title: 'Global Discovery',
              sub: 'Get scouted by organizations and build a fanbase.'),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, sub;

  const _BenefitRow(
      {required this.icon,
      required this.color,
      required this.title,
      required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glassCard(radius: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(sub, style: AppText.caption.copyWith(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active Team View ─────────────────────────────────────────────────────────
class _HasTeamView extends StatelessWidget {
  final TeamModel team;
  final ValueChanged<TeamModel> onTeamUpdated;

  const _HasTeamView({required this.team, required this.onTeamUpdated});

  @override
  Widget build(BuildContext context) {
    final logoImage = MediaService.imageProviderFor(team.logoUrl);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      child: Column(
        children: [
          // Team Identity Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration:
                AppDecorations.glowCard(glowColor: AppColors.cyan, radius: 24),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.bg3.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.cyan.withOpacity(0.5), width: 2),
                    image: logoImage == null
                        ? null
                        : DecorationImage(image: logoImage, fit: BoxFit.cover),
                  ),
                  child: logoImage == null
                      ? Center(
                          child: ShaderMask(
                            shaderCallback: (b) =>
                                AppColors.gradientCyan.createShader(b),
                            child: Text(
                              team.name.length >= 2
                                  ? team.name.substring(0, 2).toUpperCase()
                                  : team.name.toUpperCase(),
                              style: AppText.displaySm
                                  .copyWith(color: Colors.white, fontSize: 28),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name,
                          style: AppText.heading.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      GameBadge(game: team.game),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.groups_rounded,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text('${team.players.length} Active',
                              style: AppText.caption
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 14),
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(team.country ?? 'Global',
                              style: AppText.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Row
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
                      label: 'Events',
                      value: '${team.registeredTournamentIds.length}',
                      valueColor: AppColors.cyan)),
            ],
          ),
          const SizedBox(height: 24),

          // Manage Team — single button (Find Events removed)
          GlowButton(
            label: 'MANAGE TEAM',
            width: double.infinity,
            icon: Icons.settings_rounded,
            outline: true,
            onTap: () async {
              HapticFeedback.lightImpact();
              final updated = await Navigator.push<TeamModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => TeamDetailScreen(
                    team: team,
                    isViewOnly: team.registeredTournamentIds.isNotEmpty,
                  ),
                ),
              );
              if (updated != null) {
                onTeamUpdated(updated);
              }
            },
          ),
          const SizedBox(height: 40),

          SectionHeader(title: 'CURRENT ROSTER'),
          const SizedBox(height: 16),
          ...team.players.take(5).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.glassCard(radius: 16),
                  child: Row(
                    children: [
                      PlayerAvatar(player: p, size: 44),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.ign,
                                style: AppText.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(p.role ?? 'Flex Player',
                                style: AppText.caption
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.cyan.withOpacity(0.3)),
                        ),
                        child: Text(
                          p.type.label.toUpperCase(),
                          style: AppText.label
                              .copyWith(color: AppColors.cyan, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Create Team Wizard ───────────────────────────────────────────────────────
class CreateTeamScreen extends StatefulWidget {
  final String? ownerEmail;
  final String? initialContactEmail;

  const CreateTeamScreen({
    super.key,
    this.ownerEmail,
    this.initialContactEmail,
  });
  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _pageCtrl = PageController();
  int _step = 0;
  final int _totalSteps = 3;

  final _teamName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _description = TextEditingController();
  final _social = TextEditingController();
  final _customGameName = TextEditingController();

  GameTitle _game = GameTitle.mlbb;
  bool _isCustomGame = false;
  String _country = 'Cambodia';
  final List<Map<String, dynamic>> _players = [];
  File? _teamLogo;
  String? _teamLogoUrl;

  final _countries = [
    'Cambodia',
    'Thailand',
    'Vietnam',
    'Philippines',
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Global'
  ];
  final _formKeyStep1 = GlobalKey<FormState>();

  void _next() {
    HapticFeedback.lightImpact();
    if (_step == 0 && !_formKeyStep1.currentState!.validate()) return;
    if (_step == 1 && _players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one member to the roster.')),
      );
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    } else {
      _submit();
    }
  }

  void _back() {
    HapticFeedback.lightImpact();
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppDecorations.glassCard(radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                      color: AppColors.cyan, strokeWidth: 3)),
              const SizedBox(height: 24),
              Text('Encrypting Roster...',
                  style: AppText.label.copyWith(color: AppColors.cyan)),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.pop(context);
      final createdTeam = TeamModel(
        id: 'team_${DateTime.now().millisecondsSinceEpoch}',
        name: _teamName.text.trim(),
        game: _resolveGameTitle(),
        players: _players.map(_mapPlayerToModel).toList(),
        logoUrl: _teamLogoUrl,
        status: TeamStatus.pending,
        country: _country.trim().isEmpty ? null : _country.trim(),
        contactEmail: _contactEmail.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        socialLink: _social.text.trim().isEmpty ? null : _social.text.trim(),
        ownerEmail: widget.ownerEmail?.trim().toLowerCase(),
      );
      await BackendService.instance.saveTeam(createdTeam);
      if (widget.ownerEmail?.trim().isNotEmpty == true) {
        final owner =
            await BackendService.instance.getUserProfile(widget.ownerEmail!);
        if (owner != null) {
          await BackendService.instance
              .saveUserProfile(owner.copyWith(teamId: createdTeam.id));
        }
        await BackendService.instance.createNotification(
          AppNotificationModel(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
            userEmail: widget.ownerEmail!.trim().toLowerCase(),
            title: 'Team Created',
            body:
                '${createdTeam.name} has been saved to your squad hub and is ready for tournament registration.',
            type: 'team',
            createdAt: DateTime.now(),
            teamId: createdTeam.id,
          ),
        );
      }
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (_) => _SuccessDialog(
          onDone: () {
            Navigator.pop(context);
            Navigator.pop(context, createdTeam);
          },
        ),
      );
    }
  }

  void _addPlayer() async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlayerSheet(
        game: _game,
        isCustomGame: _isCustomGame,
        customGameName: _customGameName.text,
        playerIndex: _players.length,
      ),
    );
    if (result != null) setState(() => _players.add(result));
  }

  Future<void> _pickLogo() async {
    HapticFeedback.lightImpact();
    final picked =
        await MediaService.pickImage(maxWidth: 640, imageQuality: 76);
    if (picked == null) return;
    setState(() {
      _teamLogoUrl = picked.dataUrl;
      _teamLogo = picked.path == null ? null : File(picked.path!);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _teamName.dispose();
    _contactEmail.dispose();
    _description.dispose();
    _social.dispose();
    _customGameName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialContactEmail?.isNotEmpty == true) {
      _contactEmail.text = widget.initialContactEmail!;
    }
  }

  GameTitle _resolveGameTitle() {
    final value = _customGameName.text.trim().toLowerCase();
    if (value.contains('ml')) return GameTitle.mlbb;
    if (value.contains('pubg')) return GameTitle.pubg;
    if (value.contains('free fire') || value == 'ff') return GameTitle.freeFire;
    if (value.contains('valorant')) return GameTitle.valorant;
    if (value.contains('cod')) return GameTitle.cod;
    if (value.contains('football')) return GameTitle.eFootball;
    return _isCustomGame ? GameTitle.other : _game;
  }

  PlayerModel _mapPlayerToModel(Map<String, dynamic> map) {
    return PlayerModel(
      id: 'player_${DateTime.now().microsecondsSinceEpoch}_${map['ign'] ?? 'x'}',
      ign: map['ign'] as String? ?? '',
      type: map['type'] as PlayerType? ?? PlayerType.main,
      game: _resolveGameTitle(),
      fullName: map['fullName'] as String?,
      role: map['role'] as String?,
      nationality: map['nationality'] as String?,
      gameUID: map['gameUID'] as String?,
      idType: map['idType'] as String?,
      dob: map['dob'] as String?,
      jerseyNumber: (map['jerseyNumber'] as String?)?.isNotEmpty == true
          ? int.tryParse(map['jerseyNumber'] as String)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: _back,
        ),
        title: Text('REGISTER SQUAD',
            style: AppText.heading.copyWith(letterSpacing: 1)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (_step + 1) / _totalSteps),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.bg3,
              valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
              minHeight: 2,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: List.generate(
                _totalSteps,
                (i) => Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _step
                              ? AppColors.cyan
                              : i == _step
                                  ? AppColors.cyan.withOpacity(0.15)
                                  : AppColors.bg3,
                          border: Border.all(
                            color:
                                i <= _step ? AppColors.cyan : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: i < _step
                              ? const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.black)
                              : Text(
                                  '${i + 1}',
                                  style: AppText.caption.copyWith(
                                    color: i == _step
                                        ? AppColors.cyan
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ['Core Info', 'Roster', 'Review'][i],
                        style: AppText.label.copyWith(
                          color:
                              i == _step ? AppColors.cyan : AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1TeamInfo(
                  formKey: _formKeyStep1,
                  teamName: _teamName,
                  contactEmail: _contactEmail,
                  description: _description,
                  social: _social,
                  game: _game,
                  isCustomGame: _isCustomGame,
                  customGameName: _customGameName,
                  country: _country,
                  countries: _countries,
                  teamLogo: _teamLogo,
                  teamLogoUrl: _teamLogoUrl,
                  onLogoTap: _pickLogo,
                  onGameChanged: (g) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _game = g;
                      _isCustomGame = false;
                    });
                  },
                  onCustomGameToggled: (isCustom) {
                    HapticFeedback.selectionClick();
                    setState(() => _isCustomGame = isCustom);
                  },
                  onCountryChanged: (c) {
                    HapticFeedback.selectionClick();
                    setState(() => _country = c);
                  },
                ),
                _Step2Players(
                  players: _players,
                  game: _game,
                  isCustomGame: _isCustomGame,
                  customGameName: _customGameName.text,
                  onAddPlayer: _addPlayer,
                  onRemovePlayer: (i) {
                    HapticFeedback.lightImpact();
                    setState(() => _players.removeAt(i));
                  },
                ),
                _Step3Review(
                  teamName: _teamName.text,
                  game: _game,
                  isCustomGame: _isCustomGame,
                  customGameName: _customGameName.text,
                  country: _country,
                  email: _contactEmail.text,
                  playerCount: _players.length,
                  teamLogo: _teamLogo,
                  teamLogoUrl: _teamLogoUrl,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: AppColors.bg1.withOpacity(0.8),
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                      child: GlowButton(
                          label: 'BACK', outline: true, onTap: _back)),
                if (_step > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: GlowButton(
                    label: _step == _totalSteps - 1
                        ? 'SUBMIT FOR REVIEW'
                        : 'CONTINUE',
                    icon: _step == _totalSteps - 1
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wizard Step 1 ────────────────────────────────────────────────────────────
class _Step1TeamInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController teamName, contactEmail, description, social;
  final TextEditingController customGameName;
  final GameTitle game;
  final bool isCustomGame;
  final String country;
  final List<String> countries;
  final File? teamLogo;
  final String? teamLogoUrl;
  final VoidCallback onLogoTap;
  final ValueChanged<GameTitle> onGameChanged;
  final ValueChanged<bool> onCustomGameToggled;
  final ValueChanged<String> onCountryChanged;

  const _Step1TeamInfo({
    required this.formKey,
    required this.teamName,
    required this.contactEmail,
    required this.description,
    required this.social,
    required this.customGameName,
    required this.game,
    required this.isCustomGame,
    required this.country,
    required this.countries,
    required this.teamLogo,
    required this.teamLogoUrl,
    required this.onLogoTap,
    required this.onGameChanged,
    required this.onCustomGameToggled,
    required this.onCountryChanged,
  });

  @override
  State<_Step1TeamInfo> createState() => _Step1TeamInfoState();
}

class _Step1TeamInfoState extends State<_Step1TeamInfo> {
  late TextEditingController _countryCtrl;

  @override
  void initState() {
    super.initState();
    _countryCtrl = TextEditingController(text: widget.country);

    // Auto-toggle parent state to custom mode so text input is processed correctly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCustomGameToggled(true);
    });
  }

  @override
  void didUpdateWidget(_Step1TeamInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.country != oldWidget.country &&
        widget.country != _countryCtrl.text) {
      _countryCtrl.text = widget.country;
    }
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoImage = widget.teamLogo != null
        ? FileImage(widget.teamLogo!) as ImageProvider
        : MediaService.imageProviderFor(widget.teamLogoUrl);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core Infrastructure',
                style: AppText.displaySm
                    .copyWith(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
                'Establish your team\'s base identity. Required fields are marked *.',
                style: AppText.body.copyWith(height: 1.5)),
            const SizedBox(height: 32),
            _buildFieldLabel('TEAM LOGO'),
            Center(
              child: GestureDetector(
                onTap: widget.onLogoTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg3.withOpacity(0.5),
                    border: Border.all(
                      color: logoImage != null
                          ? AppColors.cyan
                          : AppColors.border.withOpacity(0.6),
                      width: logoImage != null ? 2.5 : 1.5,
                    ),
                    boxShadow: logoImage != null
                        ? [
                            BoxShadow(
                                color: AppColors.cyan.withOpacity(0.25),
                                blurRadius: 24,
                                spreadRadius: 2)
                          ]
                        : [],
                    image: logoImage != null
                        ? DecorationImage(image: logoImage, fit: BoxFit.cover)
                        : null,
                  ),
                  child: logoImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.gradientCyan.createShader(b),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 30,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text('UPLOAD LOGO',
                                style: AppText.label.copyWith(
                                    color: AppColors.textMuted, fontSize: 9)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildFieldLabel('TEAM ALIAS *'),
            TextFormField(
              controller: widget.teamName,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              textInputAction: TextInputAction.next,
              validator: (v) => v!.isEmpty ? 'Team name is required' : null,
              decoration: const InputDecoration(
                hintText: 'e.g. NEXUS GAMING',
                prefixIcon: Icon(Icons.shield_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('PRIMARY TITLE *'),

            // Fixed: Standardized styling to match the theme color of all other input containers
            TextFormField(
              controller: widget.customGameName,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter the game name'
                  : null,
              decoration: const InputDecoration(
                hintText: 'e.g. MLBB, Valorant, PUBG, Dota 2...',
                prefixIcon: Icon(Icons.sports_esports_outlined,
                    color: AppColors.textMuted, size: 20), // Matched color here
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('OPERATING REGION / COUNTRY *'),

            // Updated from Dropdown selection to editable TextFormField
            TextFormField(
              controller: _countryCtrl,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              textInputAction: TextInputAction.next,
              onChanged: (v) => widget.onCountryChanged(v),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Operating region/country is required'
                  : null,
              decoration: const InputDecoration(
                hintText: 'e.g. Cambodia, Philippines, Global',
                prefixIcon: Icon(Icons.public_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('COMMUNICATION EMAIL *'),
            TextFormField(
              controller: widget.contactEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              validator: (v) =>
                  !v!.contains('@') ? 'Valid email required' : null,
              decoration: const InputDecoration(
                hintText: 'management@team.com',
                prefixIcon: Icon(Icons.mail_outline_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('TEAM BIOGRAPHY'),
            TextFormField(
              controller: widget.description,
              maxLines: 4,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Describe your team\'s history and goals...',
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('SOCIAL TRANSMISSION (Optional)'),
            TextFormField(
              controller: widget.social,
              textInputAction: TextInputAction.done,
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Link to platform',
                prefixIcon: Icon(Icons.link_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: AppText.label.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Wizard Step 2 ────────────────────────────────────────────────────────────
class _Step2Players extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final GameTitle game;
  final bool isCustomGame;
  final String customGameName;
  final VoidCallback onAddPlayer;
  final ValueChanged<int> onRemovePlayer;

  const _Step2Players({
    required this.players,
    required this.game,
    required this.isCustomGame,
    required this.customGameName,
    required this.onAddPlayer,
    required this.onRemovePlayer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Roster',
                        style: AppText.displaySm.copyWith(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Standard configuration: 5 main + staff',
                        style: AppText.body),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                ),
                child: Text('${players.length} SECURED',
                    style: AppText.label.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: const [
              _LegendChip(color: AppColors.cyan, label: 'Main'),
              _LegendChip(color: AppColors.gold, label: 'Substitute'),
              _LegendChip(color: AppColors.purple, label: 'Staff'),
            ],
          ),
          const SizedBox(height: 24),
          if (players.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: AppDecorations.glassCard(radius: 20),
              child: Column(
                children: [
                  const Icon(Icons.person_add_disabled_rounded,
                      size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No personnel registered',
                      style: AppText.bodyMd
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            ...players.asMap().entries.map((e) {
              final p = e.value;
              final type = p['type'] as PlayerType;
              final String ign = p['ign'] as String? ?? '';

              // Crash Prevention: Fallback to '?' if the user left the IGN field blank
              final String initialLetter = ign.trim().isNotEmpty
                  ? ign.trim().substring(0, 1).toUpperCase()
                  : '?';

              final Color color = type == PlayerType.main
                  ? AppColors.cyan
                  : type == PlayerType.substitute
                      ? AppColors.gold
                      : AppColors.purple;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.glassCard(radius: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          initialLetter,
                          style: AppText.heading
                              .copyWith(color: color, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ign.isNotEmpty ? ign : 'Unnamed Player',
                              style: AppText.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${p['fullName'] ?? ''} • ${p['role'] ?? ''}',
                              style: AppText.caption),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(type.label.toUpperCase(),
                          style: AppText.label
                              .copyWith(color: color, fontSize: 9)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => onRemovePlayer(e.key),
                      child: const Icon(Icons.remove_circle_outline_rounded,
                          color: AppColors.red, size: 22),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          GlowButton(
            label: 'REGISTER PERSONNEL',
            icon: Icons.person_add_rounded,
            outline: true,
            width: double.infinity,
            onTap: onAddPlayer,
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: AppText.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Wizard Step 3 ────────────────────────────────────────────────────────────
class _Step3Review extends StatelessWidget {
  final String teamName, country, email;
  final GameTitle game;
  final bool isCustomGame;
  final String customGameName;
  final int playerCount;
  final File? teamLogo;
  final String? teamLogoUrl;

  const _Step3Review({
    required this.teamName,
    required this.game,
    required this.isCustomGame,
    required this.customGameName,
    required this.country,
    required this.email,
    required this.playerCount,
    required this.teamLogo,
    required this.teamLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String gameDisplay = isCustomGame
        ? '✏️ ${customGameName.isEmpty ? 'Custom' : customGameName}'
        : '${game.emoji} ${game.label}';
    final logoImage = teamLogo != null
        ? FileImage(teamLogo!) as ImageProvider
        : MediaService.imageProviderFor(teamLogoUrl);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Verification',
              style: AppText.displaySm
                  .copyWith(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Review your parameters before final transmission.',
              style: AppText.body),
          const SizedBox(height: 32),
          if (logoImage != null) ...[
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.cyan.withOpacity(0.5), width: 2),
                  image: DecorationImage(
                    image: logoImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppDecorations.glassCard(radius: 20),
            child: Column(
              children: [
                _ReviewRow(
                    icon: Icons.shield_rounded,
                    label: 'Designation',
                    value: teamName.isEmpty ? 'Not set' : teamName),
                Divider(
                    color: AppColors.border.withOpacity(0.5),
                    height: 1,
                    indent: 48),
                _ReviewRow(
                    icon: Icons.sports_esports_rounded,
                    label: 'Discipline',
                    value: gameDisplay),
                Divider(
                    color: AppColors.border.withOpacity(0.5),
                    height: 1,
                    indent: 48),
                _ReviewRow(
                    icon: Icons.location_on_rounded,
                    label: 'Region',
                    value: country),
                Divider(
                    color: AppColors.border.withOpacity(0.5),
                    height: 1,
                    indent: 48),
                _ReviewRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Comms',
                    value: email.isEmpty ? 'Not set' : email),
                Divider(
                    color: AppColors.border.withOpacity(0.5),
                    height: 1,
                    indent: 48),
                _ReviewRow(
                    icon: Icons.people_rounded,
                    label: 'Personnel',
                    value: '$playerCount verified'),
                Divider(
                    color: AppColors.border.withOpacity(0.5),
                    height: 1,
                    indent: 48),
                _ReviewRow(
                    icon: Icons.image_rounded,
                    label: 'Logo',
                    value: logoImage != null ? 'Uploaded ✓' : 'Not provided'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Submissions are subject to administration review. You will receive a notification once clearance is granted.',
                    style: AppText.caption.copyWith(
                        color: AppColors.gold, height: 1.5, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 16),
          Text(label,
              style: AppText.body.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Add Player Sheet (shared between create wizard and manage roster) ─────────
class _AddPlayerSheet extends StatefulWidget {
  final GameTitle game;
  final bool isCustomGame;
  final String customGameName;
  final int playerIndex;

  const _AddPlayerSheet({
    required this.game,
    required this.isCustomGame,
    required this.customGameName,
    required this.playerIndex,
  });

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _ign = TextEditingController();
  final _gameUID = TextEditingController();
  final _idNumber = TextEditingController();
  final _dob = TextEditingController();
  final _roleController = TextEditingController();
  final _nationalityController =
      TextEditingController(text: 'Cambodian'); // 👈 Added Controller

  late String _role;
  PlayerType _type = PlayerType.main;
  String _idType = 'National ID';
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
    'Substitute',
    'Coach'
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
    _role = _availableRoles.first;
    _roleController.text = _role;
    _roleController
        .addListener(() => setState(() => _role = _roleController.text));
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
      'role': _roleController.text.isNotEmpty ? _roleController.text : _role,
      'type': _type,
      'nationality':
          _nationalityController.text.trim(), // 👈 Updated to save typed text
      'idType': _idType,
      'idNumber': _idNumber.text,
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
    _idNumber.dispose();
    _dob.dispose();
    _roleController.dispose();
    _nationalityController.dispose(); // 👈 Properly disposed
    super.dispose();
  }

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
                Text('PERSONNEL ENTRY',
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
                    _buildLabel('PERSONNEL CLASSIFICATION *'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
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
                              _role = _roleController.text;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _type == t
                                  ? c.withOpacity(0.15)
                                  : AppColors.bg3.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _type == t ? c : AppColors.border),
                            ),
                            child: Text(
                              t.label.toUpperCase(),
                              style: AppText.label.copyWith(
                                  color:
                                      _type == t ? c : AppColors.textSecondary),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel('LEGAL IDENTIFICATION *'),
                    TextFormField(
                      controller: _fullName,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v!.isEmpty ? 'Legal name required' : null,
                      decoration: const InputDecoration(
                        hintText: 'Match government ID exactly',
                        prefixIcon: Icon(Icons.badge_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('IN-GAME ALIAS (IGN) *'),
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
                    const SizedBox(height: 24),
                    if (_type == PlayerType.main ||
                        _type == PlayerType.substitute) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('COMBAT ROLE *'),
                                TextFormField(
                                  controller: _roleController,
                                  style: AppText.bodyMd
                                      .copyWith(color: AppColors.textPrimary),
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Role is required'
                                      : null,
                                  onTap: () => setState(
                                      () => _showRoleSuggestions = true),
                                  onChanged: (_) => setState(
                                      () => _showRoleSuggestions = true),
                                  decoration: InputDecoration(
                                    hintText: 'Type or pick a role...',
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
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bg2,
                                      borderRadius: BorderRadius.circular(12),
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
                                              _role = r;
                                              _showRoleSuggestions = false;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.cyan
                                                      .withOpacity(0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.sports_rounded,
                                                    size: 14,
                                                    color: isSelected
                                                        ? AppColors.cyan
                                                        : AppColors.textMuted),
                                                const SizedBox(width: 10),
                                                Text(r,
                                                    style:
                                                        AppText.bodyMd.copyWith(
                                                      color: isSelected
                                                          ? AppColors.cyan
                                                          : AppColors
                                                              .textPrimary,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    )),
                                                if (isSelected) ...[
                                                  const Spacer(),
                                                  const Icon(
                                                      Icons.check_rounded,
                                                      size: 14,
                                                      color: AppColors.cyan),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('JERSEY NO.'),
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
                      const SizedBox(height: 24),
                    ],
                    _buildLabel('PLATFORM UID *'),
                    TextFormField(
                      controller: _gameUID,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v!.isEmpty ? 'UID mapping required' : null,
                      decoration: const InputDecoration(
                        hintText: 'Player exact game UID',
                        prefixIcon: Icon(Icons.tag_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('NATIONALITY *'),

                    // 👈 UPDATED: Replaced dropdown with standard text input field
                    TextFormField(
                      controller: _nationalityController,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nationality input required'
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Cambodian, Thai, Filipino',
                        prefixIcon: Icon(Icons.public_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),

                    const SizedBox(height: 24),
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
              label: 'SECURE & APPEND TO ROSTER',
              icon: Icons.check_circle_outline_rounded,
              width: double.infinity,
              onTap: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: AppText.label.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.green.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.green.withOpacity(0.2), blurRadius: 20)
                ],
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: AppColors.green, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'ROSTER INITIALIZED',
              style: AppText.heading
                  .copyWith(color: AppColors.green, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Text(
              'Your team registration has been transmitted. Awaiting administration approval.',
              style: AppText.body
                  .copyWith(height: 1.5, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GlowButton(
              label: 'ACKNOWLEDGE',
              width: double.infinity,
              gradient: LinearGradient(
                  colors: [AppColors.green, AppColors.green.withOpacity(0.6)]),
              color: AppColors.green,
              onTap: onDone,
            ),
          ],
        ),
      ),
    );
  }
}
