import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/media_service.dart';
import 'core_shared.dart';

// ── Main Tournaments List Screen ─────────────────────────────────────────────
class AdminTournamentsView extends StatefulWidget {
  const AdminTournamentsView({super.key});

  @override
  State<AdminTournamentsView> createState() => _AdminTournamentsViewState();
}

class _AdminTournamentsViewState extends State<AdminTournamentsView>
    with SingleTickerProviderStateMixin {
  bool _showArchived = false;
  final _searchCtrl = TextEditingController();
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    DB.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _switchTab(bool archived) {
    if (_showArchived == archived) return;
    setState(() {
      _showArchived = archived;
      _listKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = DB.tournaments.where((t) {
      final matchesArchive = t.isArchived == _showArchived;
      final query = _searchCtrl.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.game.label.toLowerCase().contains(query) ||
          (t.organizer ?? '').toLowerCase().contains(query);
      return matchesArchive && matchesQuery;
    }).toList();

    return ScrollConfiguration(
      behavior: _ClampingScrollBehavior(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // ── Search + Tab header (fixed, does NOT scroll) ──────────────────
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    onChanged: (_) => setState(() {}),
                    decoration: fieldDecor(
                      hint: 'Search tournaments…',
                      icon: Icons.search_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Active / Archived toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AC.bg2,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AC.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ArchiveToggle(
                            label: 'Active',
                            isActive: !_showArchived,
                            onTap: () => _switchTab(false),
                          ),
                        ),
                        Expanded(
                          child: _ArchiveToggle(
                            label: 'Archived',
                            isActive: _showArchived,
                            onTap: () => _switchTab(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Tournament list (scrollable area) ────────────────────────────
            Expanded(
              child: tournaments.isEmpty
                  ? EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: _showArchived
                          ? 'No archived tournaments'
                          : 'No tournaments found',
                      subtitle: _showArchived
                          ? 'Archived tournaments will appear here.'
                          : 'Create a new tournament to get started.',
                    )
                  : _StaggeredTournamentList(
                      key: _listKey,
                      tournaments: tournaments,
                      onOpen: _openTournament,
                      onEdit: (t) => _openEditor(existing: t),
                      onArchiveToggle: _toggleArchive,
                      onDelete: _deleteTournament,
                    ),
            ),
          ],
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _showArchived
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  key: const ValueKey('fab'),
                  backgroundColor: AC.cyan,
                  foregroundColor: AC.bg0,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => _openEditor(),
                ),
        ),
      ),
    );
  }

  Future<void> _openEditor({Tournament? existing}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentEditorScreen(existing: existing),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _openTournament(Tournament tournament) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTournamentDetailScreen(tournament: tournament),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleArchive(Tournament tournament) async {
    await DB.setTournamentArchived(tournament.id, !tournament.isArchived);
    if (mounted) {
      setState(() {
        _listKey = UniqueKey();
      });
    }
  }

  Future<void> _deleteTournament(Tournament tournament) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete ${tournament.title}?',
      message:
          'This removes the tournament from the local admin data in this dashboard copy.',
      confirmLabel: 'Delete',
      confirmColor: AC.red,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirm) return;
    await DB.deleteTournament(tournament.id);
    if (mounted) setState(() {});
  }
}

// ── Forces ClampingScrollPhysics on all scrollables, overrides iOS bounce ────
class _ClampingScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

// ── Staggered animated list ───────────────────────────────────────────────────
class _StaggeredTournamentList extends StatefulWidget {
  final List<Tournament> tournaments;
  final void Function(Tournament) onOpen;
  final void Function(Tournament) onEdit;
  final void Function(Tournament) onArchiveToggle;
  final void Function(Tournament) onDelete;

  const _StaggeredTournamentList({
    super.key,
    required this.tournaments,
    required this.onOpen,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  @override
  State<_StaggeredTournamentList> createState() =>
      _StaggeredTournamentListState();
}

class _StaggeredTournamentListState extends State<_StaggeredTournamentList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 300 + widget.tournaments.length.clamp(0, 10) * 55),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: widget.tournaments.length,
      itemBuilder: (context, index) {
        final t = widget.tournaments[index];
        final stagger = (index * 0.065).clamp(0.0, 0.72);
        final end = (stagger + 0.38).clamp(0.0, 1.0);
        final curve = Interval(stagger, end, curve: Curves.easeOutCubic);
        final fade = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: _ctrl, curve: curve));
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: curve));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: RepaintBoundary(
              child: _TournamentListCard(
                tournament: t,
                onOpen: () => widget.onOpen(t),
                onEdit: () => widget.onEdit(t),
                onArchiveToggle: () => widget.onArchiveToggle(t),
                onDelete: () => widget.onDelete(t),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Archive toggle chip ───────────────────────────────────────────────────────
class _ArchiveToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ArchiveToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? AC.gradPrimary : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: isActive ? AC.bg0 : AC.textMuted,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// ── Redesigned Tournament List Card ─────────────────────────────────────────
class _TournamentListCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  const _TournamentListCard({
    required this.tournament,
    required this.onOpen,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = tourStatusColor(tournament.status);
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.22)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // ── Top colour accent bar ──────────────────────────────────
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.3)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Identity row ────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo / emoji badge
                        AdminLogoBadge(
                          imageUrl: tournament.resolvedLogoUrl,
                          fallback: tournament.game.label,
                          size: 52,
                          radius: 14,
                        ),
                        const SizedBox(width: 12),
                        // Title + meta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tournament.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AC.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tournament.game.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AT.caption,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  StatusBadge(
                                    label: tournament.status.label,
                                    color: statusColor,
                                  ),
                                  if (tournament.pendingCount > 0) ...[
                                    const SizedBox(width: 6),
                                    StatusBadge(
                                      label:
                                          '${tournament.pendingCount} pending',
                                      color: AC.gold,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Menu
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: AC.textSecondary,
                            size: 20,
                          ),
                          color: AC.bg3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'archive') onArchiveToggle();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'archive',
                              child: Text(
                                tournament.isArchived ? 'Restore' : 'Archive',
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ── Stats row ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AC.bg3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _CardStat(
                            icon: Icons.groups_rounded,
                            label: 'Teams',
                            value:
                                '${tournament.registrants.length}/${tournament.maxTeams}',
                            tone: AC.cyan,
                          ),
                          _vertDivider(),
                          _CardStat(
                            icon: Icons.payments_rounded,
                            label: 'Prize',
                            value: tournament.prize,
                            tone: AC.gold,
                          ),
                          _vertDivider(),
                          _CardStat(
                            icon: Icons.account_tree_rounded,
                            label: 'Format',
                            value: tournament.format.label,
                            tone: AC.violet,
                          ),
                        ],
                      ),
                    ),
                    // ── Organizer + location footer ─────────────────────
                    if ((tournament.organizer != null &&
                            tournament.organizer!.isNotEmpty) ||
                        (tournament.location != null &&
                            tournament.location!.isNotEmpty)) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (tournament.organizer?.isNotEmpty == true) ...[
                            const Icon(Icons.business_rounded,
                                size: 12, color: AC.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                tournament.organizer!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AT.caption,
                              ),
                            ),
                          ],
                          if (tournament.organizer?.isNotEmpty == true &&
                              tournament.location?.isNotEmpty == true)
                            const SizedBox(width: 12),
                          if (tournament.location?.isNotEmpty == true) ...[
                            const Icon(Icons.place_rounded,
                                size: 12, color: AC.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                tournament.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AT.caption,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vertDivider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: AC.border,
      );
}

class _CardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  const _CardStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: tone),
              const SizedBox(width: 4),
              Text(
                label,
                style: AT.label.copyWith(fontSize: 9, color: AC.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTournamentSignal extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _MiniTournamentSignal({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AC.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AT.label.copyWith(fontSize: 9)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AT.body.copyWith(color: tone, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TournamentEditorScreen extends StatefulWidget {
  final Tournament? existing;

  const TournamentEditorScreen({super.key, this.existing});

  @override
  State<TournamentEditorScreen> createState() => _TournamentEditorScreenState();
}

class _TournamentEditorScreenState extends State<TournamentEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _prizeCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _requirementsCtrl;
  late final TextEditingController _organizerCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _endDateCtrl;
  late final TextEditingController _regDeadlineCtrl;
  late final TextEditingController _maxTeamsCtrl;
  late final TextEditingController _gameCtrl;
  late final TextEditingController _logoUrlCtrl;
  late TourStatus _status;
  late TourFormat _format;
  late GameCtx _game;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _prizeCtrl = TextEditingController(text: existing?.prize ?? '');
    _typeCtrl = TextEditingController(text: existing?.type ?? 'Squad');
    _descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    _requirementsCtrl = TextEditingController(
      text: existing?.requirements ?? '',
    );
    _organizerCtrl = TextEditingController(text: existing?.organizer ?? '');
    _locationCtrl = TextEditingController(text: existing?.location ?? '');
    _startDateCtrl = TextEditingController(text: existing?.startDate ?? '');
    _endDateCtrl = TextEditingController(text: existing?.endDate ?? '');
    _regDeadlineCtrl = TextEditingController(text: existing?.regDeadline ?? '');
    _maxTeamsCtrl = TextEditingController(text: '${existing?.maxTeams ?? 16}');
    _game = existing?.game ?? GameCtx.mlbb;
    _status = existing?.status ?? TourStatus.upcoming;
    _format = existing?.format ?? TourFormat.singleElim;
    _gameCtrl = TextEditingController(text: _game.label);
    _logoUrlCtrl = TextEditingController(
      text: existing?.logoUrl ?? defaultGameLogoUrl(_game) ?? '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prizeCtrl.dispose();
    _typeCtrl.dispose();
    _descriptionCtrl.dispose();
    _requirementsCtrl.dispose();
    _organizerCtrl.dispose();
    _locationCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _regDeadlineCtrl.dispose();
    _maxTeamsCtrl.dispose();
    _gameCtrl.dispose();
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      backgroundColor: AC.bg1,
      appBar: AppBar(
        backgroundColor: AC.bg0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isEditing ? 'Edit Tournament' : 'Create Tournament',
          style: AT.heading,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AC.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AC.cyan, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          const SizedBox(height: 22),
          const SectionHdr(title: 'BASIC INFORMATION'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecor(),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Tournament title',
                    icon: Icons.emoji_events_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prizeCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Prize pool (e.g. \$5,000)',
                    icon: Icons.payments_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _typeCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Tournament type (e.g. 5v5, Squad)',
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<GameCtx>(
                      controller: _gameCtrl,
                      width: constraints.maxWidth,
                      enableSearch: true,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      initialSelection: _game,
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: AC.bg3,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AC.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AC.cyan,
                            width: 1.4,
                          ),
                        ),
                      ),
                      hintText: 'Type or select a game',
                      onSelected: (game) {
                        if (game == null) return;
                        setState(() {
                          _game = game;
                          _gameCtrl.text = game.label;
                          if (_logoUrlCtrl.text.trim().isEmpty) {
                            _logoUrlCtrl.text = defaultGameLogoUrl(game) ?? '';
                          }
                        });
                      },
                      dropdownMenuEntries: GameCtx.values
                          .map(
                            (game) => DropdownMenuEntry<GameCtx>(
                              value: game,
                              label: game.label,
                              leadingIcon: Text(game.emoji),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AC.bg2,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AC.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('GAME LOGO', style: AT.label),
                          ),
                          GestureDetector(
                            onTap: _showLogoComposer,
                            child: Text(
                              'Upload / Edit',
                              style: AT.caption.copyWith(
                                color: AC.cyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          AdminLogoBadge(
                            imageUrl: _logoUrlCtrl.text.trim().isEmpty
                                ? defaultGameLogoUrl(_game)
                                : _logoUrlCtrl.text.trim(),
                            fallback: _gameCtrl.text.trim().isEmpty
                                ? _game.label
                                : _gameCtrl.text.trim(),
                            size: 54,
                            radius: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _logoUrlCtrl,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(color: AC.textPrimary),
                              decoration: fieldDecor(
                                hint: 'Paste logo image URL',
                                icon: Icons.image_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHdr(title: 'TIMING AND STRUCTURE'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecor(),
            child: Column(
              children: [
                DropdownButtonFormField<TourStatus>(
                  initialValue: _status,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                    hint: 'Status',
                    icon: Icons.radio_button_checked_rounded,
                  ),
                  items: TourStatus.values
                      .map(
                        (status) => DropdownMenuItem<TourStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status == null) return;
                    setState(() => _status = status);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TourFormat>(
                  initialValue: _format,
                  dropdownColor: AC.bg3,
                  style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                  decoration: fieldDecor(
                    hint: 'Format',
                    icon: Icons.account_tree_rounded,
                  ),
                  items: TourFormat.values
                      .map(
                        (format) => DropdownMenuItem<TourFormat>(
                          value: format,
                          child: Text(format.label),
                        ),
                      )
                      .toList(),
                  onChanged: (format) {
                    if (format == null) return;
                    setState(() => _format = format);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxTeamsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Maximum teams',
                    icon: Icons.groups_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _startDateCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Start date (YYYY-MM-DD)',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _endDateCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'End date (YYYY-MM-DD)',
                    icon: Icons.event_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regDeadlineCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Registration deadline (YYYY-MM-DD)',
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHdr(title: 'DETAILS'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecor(),
            child: Column(
              children: [
                TextField(
                  controller: _organizerCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Organizer',
                    icon: Icons.business_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Location',
                    icon: Icons.place_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Tournament description',
                    icon: Icons.description_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _requirementsCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Requirements and rules',
                    icon: Icons.rule_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradButton(
            label: isEditing ? 'SAVE CHANGES' : 'CREATE TOURNAMENT',
            width: double.infinity,
            icon: Icons.check_rounded,
            onTap: _saveTournament,
          ),
        ),
      ),
    );
  }

  void _saveTournament() async {
    final resolvedGame = _resolveGameFromText(_gameCtrl.text.trim()) ?? _game;
    final maxTeams = int.tryParse(_maxTeamsCtrl.text.trim()) ?? 16;
    final existing = widget.existing;

    if (existing != null) {
      existing.title = _titleCtrl.text.trim();
      existing.prize = _prizeCtrl.text.trim();
      existing.type =
          _typeCtrl.text.trim().isEmpty ? existing.type : _typeCtrl.text.trim();
      existing.game = resolvedGame;
      existing.logoUrl =
          _logoUrlCtrl.text.trim().isEmpty ? null : _logoUrlCtrl.text.trim();
      existing.status = _status;
      existing.format = _format;
      existing.maxTeams = maxTeams;
      existing.startDate = _startDateCtrl.text.trim();
      existing.endDate = _endDateCtrl.text.trim();
      existing.regDeadline = _regDeadlineCtrl.text.trim();
      existing.organizer = _organizerCtrl.text.trim();
      existing.location = _locationCtrl.text.trim();
      existing.description = _descriptionCtrl.text.trim();
      existing.requirements = _requirementsCtrl.text.trim();
      await DB.saveTournament(existing);
    } else {
      await DB.saveTournament(
        Tournament(
          id: 'tour_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleCtrl.text.trim(),
          game: resolvedGame,
          logoUrl: _logoUrlCtrl.text.trim().isEmpty
              ? null
              : _logoUrlCtrl.text.trim(),
          status: _status,
          prize: _prizeCtrl.text.trim(),
          type: _typeCtrl.text.trim().isEmpty ? 'Squad' : _typeCtrl.text.trim(),
          format: _format,
          startDate: _startDateCtrl.text.trim(),
          endDate: _endDateCtrl.text.trim(),
          regDeadline: _regDeadlineCtrl.text.trim(),
          organizer: _organizerCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          requirements: _requirementsCtrl.text.trim(),
          maxTeams: maxTeams,
          registrants: [],
          schedules: [],
          bracketRounds: [],
          standings: [],
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  GameCtx? _resolveGameFromText(String value) {
    if (value.isEmpty) return null;
    for (final game in GameCtx.values) {
      if (game.label.toLowerCase() == value.toLowerCase()) {
        return game;
      }
    }
    return _game;
  }

  void _showLogoComposer() {
    final draftCtrl = TextEditingController(text: _logoUrlCtrl.text.trim());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AC.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AC.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Game Logo Branding', style: AT.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Paste a real logo image URL or auto-fill the default logo for the selected game.',
                    style: AT.body.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AdminLogoBadge(
                      imageUrl: draftCtrl.text.trim().isEmpty
                          ? defaultGameLogoUrl(_game)
                          : draftCtrl.text.trim(),
                      fallback: _game.label,
                      size: 84,
                      radius: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: draftCtrl,
                    onChanged: (_) => setModalState(() {}),
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'https://...',
                      icon: Icons.link_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineBtn(
                          label: 'Use Default',
                          icon: Icons.auto_awesome_rounded,
                          onTap: () {
                            draftCtrl.text = defaultGameLogoUrl(_game) ?? '';
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlineBtn(
                          label: 'Device',
                          color: AC.violet,
                          icon: Icons.add_photo_alternate_rounded,
                          onTap: () async {
                            final picked = await MediaService.pickImage(
                              maxWidth: 640,
                              imageQuality: 76,
                            );
                            if (picked == null) return;
                            draftCtrl.text = picked.dataUrl;
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineBtn(
                          label: 'Clear',
                          color: AC.textSecondary,
                          icon: Icons.close_rounded,
                          onTap: () {
                            draftCtrl.clear();
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GradButton(
                    label: 'SAVE LOGO',
                    width: double.infinity,
                    icon: Icons.check_rounded,
                    onTap: () {
                      setState(() {
                        _logoUrlCtrl.text = draftCtrl.text.trim();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tournament Detail Screen ──────────────────────────────────────────────────
class AdminTournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const AdminTournamentDetailScreen({super.key, required this.tournament});

  @override
  State<AdminTournamentDetailScreen> createState() =>
      _AdminTournamentDetailScreenState();
}

class _AdminTournamentDetailScreenState
    extends State<AdminTournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    _TabItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _TabItem(icon: Icons.groups_rounded, label: 'Teams'),
    _TabItem(icon: Icons.calendar_month_rounded, label: 'Schedule'),
    _TabItem(icon: Icons.account_tree_rounded, label: 'Bracket'),
    _TabItem(icon: Icons.leaderboard_rounded, label: 'Standings'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _persistTournament() {
    setState(() {});
    DB.saveTournament(widget.tournament);
  }

  @override
  Widget build(BuildContext context) {
    final tournament = widget.tournament;
    final statusColor = tourStatusColor(tournament.status);

    return Scaffold(
      backgroundColor: AC.bg1,
      // ── Fixed AppBar — never expands, never stretches ──────────────────
      appBar: AppBar(
        backgroundColor: AC.bg0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AC.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            AdminLogoBadge(
              imageUrl: tournament.resolvedLogoUrl,
              fallback: tournament.game.label,
              size: 32,
              radius: 9,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AC.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    tournament.game.label,
                    style: const TextStyle(
                      color: AC.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: StatusBadge(
              label: tournament.status.label,
              color: statusColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AC.cyan),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => TournamentEditorScreen(existing: tournament),
                ),
              );
              if (updated == true && mounted) setState(() {});
            },
          ),
        ],
        // ── Tab bar pinned below app bar ──────────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: const BoxDecoration(
              color: AC.bg0,
              border: Border(bottom: BorderSide(color: AC.border)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AC.cyan,
              indicatorWeight: 2,
              labelColor: AC.cyan,
              unselectedLabelColor: AC.textMuted,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs
                  .map((t) => Tab(
                        height: 46,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.icon, size: 14),
                            const SizedBox(width: 6),
                            Text(t.label.toUpperCase()),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        physics: const ClampingScrollPhysics(),
        children: [
          _TournamentOverviewTab(tournament: tournament),
          _TournamentTeamsTab(
            tournament: tournament,
            onChanged: _persistTournament,
          ),
          _TournamentScheduleTab(
            tournament: tournament,
            onChanged: _persistTournament,
          ),
          _TournamentBracketTab(
            tournament: tournament,
            onChanged: _persistTournament,
          ),
          _TournamentStandingsTab(
            tournament: tournament,
            onChanged: _persistTournament,
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _TournamentOverviewTab extends StatelessWidget {
  final Tournament tournament;

  const _TournamentOverviewTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Registered',
                  value:
                      '${tournament.registrants.length}/${tournament.maxTeams}',
                  tone: AC.cyan,
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewStat(
                  label: 'Pending',
                  value: '${tournament.pendingCount}',
                  tone: AC.gold,
                  icon: Icons.hourglass_top_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewStat(
                  label: 'Format',
                  value: tournament.format.label,
                  tone: AC.violet,
                  icon: Icons.account_tree_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHdr(title: 'DESCRIPTION'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: cardDecor(),
            child: Text(
              tournament.description?.trim().isNotEmpty == true
                  ? tournament.description!
                  : 'No description provided.',
              style: AT.body,
            ),
          ),
          const SizedBox(height: 24),
          const SectionHdr(title: 'DETAILS'),
          Container(
            decoration: cardDecor(),
            child: Column(
              children: [
                _DetailRow(label: 'Game', value: tournament.game.label),
                _DetailRow(label: 'Type', value: tournament.type),
                _DetailRow(label: 'Prize', value: tournament.prize),
                _DetailRow(
                  label: 'Start',
                  value: tournament.startDate?.isNotEmpty == true
                      ? tournament.startDate!
                      : 'TBA',
                ),
                _DetailRow(
                  label: 'End',
                  value: tournament.endDate?.isNotEmpty == true
                      ? tournament.endDate!
                      : 'TBA',
                ),
                _DetailRow(
                  label: 'Reg Deadline',
                  value: tournament.regDeadline?.isNotEmpty == true
                      ? tournament.regDeadline!
                      : 'TBA',
                ),
                _DetailRow(
                  label: 'Organizer',
                  value: tournament.organizer?.isNotEmpty == true
                      ? tournament.organizer!
                      : 'TBA',
                ),
                _DetailRow(
                  label: 'Location',
                  value: tournament.location?.isNotEmpty == true
                      ? tournament.location!
                      : 'TBA',
                  isLast: true,
                ),
              ],
            ),
          ),
          if (tournament.requirements?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 24),
            const SectionHdr(title: 'REQUIREMENTS'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: cardDecor(border: AC.cyan.withOpacity(0.2)),
              child: Text(tournament.requirements!, style: AT.body),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final IconData icon;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecor(border: tone.withOpacity(0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(height: 10),
          Text(
            value,
            style: AT.body.copyWith(color: tone, fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(label, style: AT.label.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            isLast ? null : const Border(bottom: BorderSide(color: AC.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AT.caption.copyWith(color: AC.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AT.body.copyWith(
                color: AC.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentTeamsTab extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onChanged;

  const _TournamentTeamsTab({
    required this.tournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final teams = tournament.registrants;
    if (teams.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        title: 'No teams yet',
        subtitle:
            'Registered teams will appear here once entries are submitted.',
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final tone = approvalColor(team.state);
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: cardDecor(border: tone.withOpacity(0.18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.teamName, style: AT.heading),
                        const SizedBox(height: 4),
                        Text(
                          '${team.region} • ${team.lineupCount} players',
                          style: AT.caption,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: team.state.label, color: tone),
                ],
              ),
              const SizedBox(height: 14),
              _TeamLineupSnapshot(team: team),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlineBtn(
                      label: 'Edit Lineup',
                      icon: Icons.edit_rounded,
                      onTap: () {
                        _showLineupEditor(context, team, onChanged);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlineBtn(
                      label: 'View Roster',
                      color: AC.textSecondary,
                      icon: Icons.visibility_rounded,
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _RosterPreviewSheet(team: team),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamLineupSnapshot extends StatelessWidget {
  final TeamReg team;

  const _TeamLineupSnapshot({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AC.bg0.withOpacity(0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ROSTER', style: AT.label),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: team.roster
                .map(
                  (player) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AC.bg3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AC.border),
                    ),
                    child: Text(
                      player,
                      style: AT.caption.copyWith(color: AC.textPrimary),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StaffMiniCard(
                  title: 'Coach',
                  value: team.coach,
                  tone: AC.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StaffMiniCard(
                  title: 'Assistant',
                  value: team.assistantCoach,
                  tone: AC.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffMiniCard extends StatelessWidget {
  final String title;
  final String? value;
  final Color tone;

  const _StaffMiniCard({
    required this.title,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            (value == null || value!.trim().isEmpty) ? 'Not set' : value!,
            style: AT.body.copyWith(color: tone, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RosterPreviewSheet extends StatelessWidget {
  final TeamReg team;

  const _RosterPreviewSheet({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AC.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AC.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(team.teamName, style: AT.heading),
            const SizedBox(height: 14),
            ...team.roster.asMap().entries.map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: cardDecor(),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AC.cyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
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
                            entry.value,
                            style: AT.body.copyWith(
                              color: AC.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

void _showLineupEditor(
  BuildContext context,
  TeamReg team,
  VoidCallback onChanged,
) {
  final coachCtrl = TextEditingController(text: team.coach ?? '');
  final assistantCtrl = TextEditingController(text: team.assistantCoach ?? '');
  final managerCtrl = TextEditingController(text: team.manager ?? '');
  final rosterCtrls =
      team.roster.map((player) => TextEditingController(text: player)).toList();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AC.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AC.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Update Lineup', style: AT.heading),
                  const SizedBox(height: 16),
                  TextField(
                    controller: coachCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Coach name',
                      icon: Icons.badge_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: assistantCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Assistant coach name',
                      icon: Icons.support_agent_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: managerCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Manager name',
                      icon: Icons.manage_accounts_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionHdr(title: 'ROSTER PLAYERS'),
                  ...rosterCtrls.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: entry.value,
                                  style: const TextStyle(color: AC.textPrimary),
                                  decoration: fieldDecor(
                                    hint: 'Player ${entry.key + 1}',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => setModalState(
                                  () => rosterCtrls.removeAt(entry.key),
                                ),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AC.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AC.red.withOpacity(0.26),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AC.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 4),
                  OutlineBtn(
                    label: 'Add Player',
                    icon: Icons.add_rounded,
                    onTap: () => setModalState(
                      () => rosterCtrls.add(TextEditingController()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradButton(
                    label: 'SAVE LINEUP',
                    width: double.infinity,
                    icon: Icons.check_rounded,
                    onTap: () {
                      team.coach = coachCtrl.text.trim();
                      team.assistantCoach = assistantCtrl.text.trim();
                      team.manager = managerCtrl.text.trim();
                      team.roster = rosterCtrls
                          .map((controller) => controller.text.trim())
                          .where((player) => player.isNotEmpty)
                          .toList();
                      onChanged();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _TournamentScheduleTab extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onChanged;

  const _TournamentScheduleTab({
    required this.tournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final schedules = tournament.schedules;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Manage match schedules and venue details.',
                  style: AT.body,
                ),
              ),
              const SizedBox(width: 12),
              OutlineBtn(
                label: 'Add Match',
                icon: Icons.add_rounded,
                onTap: () => _showScheduleEditor(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: schedules.isEmpty
              ? const EmptyState(
                  icon: Icons.schedule_rounded,
                  title: 'No matches scheduled',
                  subtitle:
                      'Add a schedule entry to manage the event timeline.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final match = schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: cardDecor(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.round,
                                      style: AT.caption.copyWith(
                                        color: AC.cyan,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${match.teamA} vs ${match.teamB}',
                                      style: AT.heading.copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: AC.textSecondary,
                                ),
                                color: AC.bg3,
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _showScheduleEditor(
                                      context,
                                      existing: match,
                                    );
                                  } else if (value == 'delete') {
                                    final confirm = await showConfirmDialog(
                                      context,
                                      title: 'Delete match schedule?',
                                      message:
                                          'This will remove the scheduled match from the list.',
                                      confirmLabel: 'Delete',
                                      confirmColor: AC.red,
                                      icon: Icons.delete_outline_rounded,
                                    );
                                    if (confirm) {
                                      tournament.schedules.remove(match);
                                      onChanged();
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniTournamentSignal(
                                  label: 'Date',
                                  value: match.date,
                                  tone: AC.cyan,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniTournamentSignal(
                                  label: 'Time',
                                  value: match.time,
                                  tone: AC.green,
                                ),
                              ),
                            ],
                          ),
                          if (match.venue != null &&
                              match.venue!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Venue: ${match.venue}',
                                style: AT.caption.copyWith(
                                  color: AC.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showScheduleEditor(BuildContext context, {ScheduleEntry? existing}) {
    final roundCtrl = TextEditingController(text: existing?.round ?? '');
    final teamACtrl = TextEditingController(text: existing?.teamA ?? '');
    final teamBCtrl = TextEditingController(text: existing?.teamB ?? '');
    final dateCtrl = TextEditingController(text: existing?.date ?? '');
    final timeCtrl = TextEditingController(text: existing?.time ?? '');
    final venueCtrl = TextEditingController(text: existing?.venue ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AC.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AC.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null
                      ? 'Add Match Schedule'
                      : 'Edit Match Schedule',
                  style: AT.heading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roundCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Round or stage',
                    icon: Icons.flag_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teamACtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Team A',
                    icon: Icons.group_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teamBCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Team B',
                    icon: Icons.group_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Date (YYYY-MM-DD)',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Time (HH:MM)',
                    icon: Icons.access_time_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Venue',
                    icon: Icons.place_rounded,
                  ),
                ),
                const SizedBox(height: 20),
                GradButton(
                  label: existing == null ? 'ADD MATCH' : 'SAVE CHANGES',
                  width: double.infinity,
                  icon: Icons.check_rounded,
                  onTap: () {
                    if (existing != null) {
                      existing.round = roundCtrl.text.trim();
                      existing.teamA = teamACtrl.text.trim();
                      existing.teamB = teamBCtrl.text.trim();
                      existing.date = dateCtrl.text.trim();
                      existing.time = timeCtrl.text.trim();
                      existing.venue = venueCtrl.text.trim();
                    } else {
                      tournament.schedules.add(
                        ScheduleEntry(
                          id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
                          round: roundCtrl.text.trim(),
                          teamA: teamACtrl.text.trim(),
                          teamB: teamBCtrl.text.trim(),
                          date: dateCtrl.text.trim(),
                          time: timeCtrl.text.trim(),
                          venue: venueCtrl.text.trim(),
                        ),
                      );
                    }
                    onChanged();
                    Navigator.pop(context);
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

class _TournamentBracketTab extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onChanged;

  const _TournamentBracketTab({
    required this.tournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final rounds = tournament.bracketRounds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Pan vertically through bracket rounds.',
                  style: AT.body,
                ),
              ),
              const SizedBox(width: 12),
              OutlineBtn(
                label: 'Add Round',
                icon: Icons.add_rounded,
                onTap: () => _showAddRoundDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: rounds.isEmpty
              ? const EmptyState(
                  icon: Icons.account_tree_outlined,
                  title: 'No bracket rounds yet',
                  subtitle:
                      'Create a round to begin building the tournament tree.',
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 256,
                    child: ListView.separated(
                      key: PageStorageKey(
                        'admin_bracket_vertical_${tournament.id}',
                      ),
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
                      itemCount: rounds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final round = rounds[index];

                        return _BracketRoundColumn(
                          tournament: tournament,
                          roundIndex: index,
                          round: round,
                          onChanged: onChanged,
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddRoundDialog(BuildContext context) {
    final nameCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Bracket Round', style: AT.heading),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AC.textPrimary),
                decoration: fieldDecor(
                  hint: 'Round name',
                  icon: Icons.flag_rounded,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlineBtn(
                      label: 'Cancel',
                      color: AC.textSecondary,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradButton(
                      label: 'Add',
                      onTap: () {
                        tournament.bracketRounds.add(
                          BracketRound(
                            id: 'round_${DateTime.now().millisecondsSinceEpoch}',
                            roundName: nameCtrl.text.trim(),
                            matches: [
                              MatchNode(
                                id: 'match_${DateTime.now().millisecondsSinceEpoch}',
                                teamA: 'TBD',
                                teamB: 'TBD',
                              ),
                            ],
                          ),
                        );
                        onChanged();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BracketRoundColumn extends StatelessWidget {
  final Tournament tournament;
  final int roundIndex;
  final BracketRound round;
  final VoidCallback onChanged;

  const _BracketRoundColumn({
    required this.tournament,
    required this.roundIndex,
    required this.round,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AC.bg3,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AC.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    round.roundName,
                    style: AT.subheading.copyWith(color: AC.cyan),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Delete round?',
                      message:
                          'All matches inside this round will be removed from the bracket.',
                      confirmLabel: 'Delete',
                      confirmColor: AC.red,
                      icon: Icons.delete_outline_rounded,
                    );
                    if (confirm) {
                      tournament.bracketRounds.remove(round);
                      onChanged();
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AC.red,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...round.matches.map(
            (match) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: cardDecor(
                border:
                    match.isFinalized ? AC.green.withOpacity(0.2) : AC.border,
              ),
              child: Column(
                children: [
                  if ((match.date ?? '').isNotEmpty ||
                      (match.time ?? '').isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${match.date ?? ''} ${match.time ?? ''}'.trim(),
                        style: AT.caption.copyWith(color: AC.textSecondary),
                      ),
                    ),
                  if ((match.date ?? '').isNotEmpty ||
                      (match.time ?? '').isNotEmpty)
                    const SizedBox(height: 10),
                  _BracketTeamRow(
                    name: match.teamA,
                    score: match.scoreA,
                    winner: match.winner == match.teamA,
                  ),
                  const SizedBox(height: 8),
                  _BracketTeamRow(
                    name: match.teamB,
                    score: match.scoreB,
                    winner: match.winner == match.teamB,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineBtn(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          onTap: () => _showMatchEditor(context, match),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlineBtn(
                          label: 'Delete',
                          color: AC.red,
                          icon: Icons.delete_outline_rounded,
                          onTap: () async {
                            final confirm = await showConfirmDialog(
                              context,
                              title: 'Delete match?',
                              message:
                                  'This match will be removed from the bracket round.',
                              confirmLabel: 'Delete',
                              confirmColor: AC.red,
                              icon: Icons.delete_outline_rounded,
                            );
                            if (confirm) {
                              round.matches.remove(match);
                              onChanged();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          OutlineBtn(
            label: 'Add Match',
            icon: Icons.add_rounded,
            onTap: () {
              round.matches.add(
                MatchNode(
                  id: 'match_${DateTime.now().millisecondsSinceEpoch}',
                  teamA: 'TBD',
                  teamB: 'TBD',
                ),
              );
              onChanged();
            },
          ),
        ],
      ),
    );
  }

  void _showMatchEditor(BuildContext context, MatchNode match) {
    final teamACtrl = TextEditingController(text: match.teamA);
    final teamBCtrl = TextEditingController(text: match.teamB);
    final scoreACtrl = TextEditingController(text: '${match.scoreA}');
    final scoreBCtrl = TextEditingController(text: '${match.scoreB}');
    final dateCtrl = TextEditingController(text: match.date ?? '');
    final timeCtrl = TextEditingController(text: match.time ?? '');
    String winner = match.winner ?? match.teamA;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AC.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AC.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Edit Match', style: AT.heading),
                  const SizedBox(height: 16),
                  TextField(
                    controller: teamACtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Team A',
                      icon: Icons.group_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: teamBCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Team B',
                      icon: Icons.group_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: scoreACtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AC.textPrimary),
                          decoration: fieldDecor(
                            hint: 'Score A',
                            icon: Icons.scoreboard_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: scoreBCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AC.textPrimary),
                          decoration: fieldDecor(
                            hint: 'Score B',
                            icon: Icons.scoreboard_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Date (YYYY-MM-DD)',
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeCtrl,
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Time (HH:MM)',
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: winner,
                    dropdownColor: AC.bg3,
                    style: const TextStyle(color: AC.textPrimary, fontSize: 14),
                    decoration: fieldDecor(
                      hint: 'Winner',
                      icon: Icons.emoji_events_rounded,
                    ),
                    items: [teamACtrl.text, teamBCtrl.text]
                        .where((name) => name.trim().isNotEmpty)
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => winner = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  GradButton(
                    label: 'SAVE MATCH',
                    width: double.infinity,
                    icon: Icons.check_rounded,
                    onTap: () {
                      match.teamA = teamACtrl.text.trim();
                      match.teamB = teamBCtrl.text.trim();
                      match.scoreA = int.tryParse(scoreACtrl.text.trim()) ?? 0;
                      match.scoreB = int.tryParse(scoreBCtrl.text.trim()) ?? 0;
                      match.date = dateCtrl.text.trim();
                      match.time = timeCtrl.text.trim();
                      match.winner = winner;
                      match.isFinalized = true;

                      if (roundIndex + 1 < tournament.bracketRounds.length) {
                        final nextRound =
                            tournament.bracketRounds[roundIndex + 1];
                        if (nextRound.matches.isNotEmpty) {
                          final nextMatch = nextRound.matches.first;
                          if (nextMatch.teamA == 'TBD') {
                            nextMatch.teamA = winner;
                          } else if (nextMatch.teamB == 'TBD') {
                            nextMatch.teamB = winner;
                          }
                        }
                      }

                      onChanged();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BracketTeamRow extends StatelessWidget {
  final String name;
  final int score;
  final bool winner;

  const _BracketTeamRow({
    required this.name,
    required this.score,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: winner ? AC.green.withOpacity(0.08) : AC.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: winner ? AC.green.withOpacity(0.24) : AC.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AT.body.copyWith(
                color: winner ? AC.textPrimary : AC.textSecondary,
                fontWeight: winner ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$score',
            style: AT.body.copyWith(
              color: winner ? AC.green : AC.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentStandingsTab extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onChanged;

  const _TournamentStandingsTab({
    required this.tournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final standings = tournament.standings;
    return Column(
      children: [
        // ── Header Bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Standings', style: AT.subheading),
                    const SizedBox(height: 2),
                    Text(
                      '${standings.length} team${standings.length == 1 ? '' : 's'} ranked',
                      style: AT.caption,
                    ),
                  ],
                ),
              ),
              OutlineBtn(
                label: 'Add',
                icon: Icons.add_rounded,
                onTap: () => _showStandingEditor(context),
              ),
            ],
          ),
        ),

        // ── Modern Legend Strip ─────────────────────────────────────────────
        if (standings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                _legendDot(const Color(0xFF00C853), 'Top 2'),
                const SizedBox(width: 16),
                _legendDot(const Color(0xFFFFA000), '3rd–4th'),
                const SizedBox(width: 16),
                _legendDot(AC.red, 'Relegation'),
              ],
            ),
          ),

        // ── Clean List View ─────────────────────────────────────────────────
        Expanded(
          child: standings.isEmpty
              ? const EmptyState(
                  icon: Icons.leaderboard_outlined,
                  title: 'No standings yet',
                  subtitle: 'Add team standings to display rankings here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: standings.length,
                  itemBuilder: (context, index) {
                    final standing = standings[index];
                    return _StandingCard(
                      rank: index + 1,
                      total: standings.length,
                      standing: standing,
                      onTap: () => _showStandingEditor(
                        context,
                        existing: standing,
                      ),
                      onDelete: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Delete standing?',
                          message: 'The selected standing row will be removed.',
                          confirmLabel: 'Delete',
                          confirmColor: AC.red,
                          icon: Icons.delete_outline_rounded,
                        );
                        if (confirm) {
                          tournament.standings.remove(standing);
                          onChanged();
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AT.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showStandingEditor(BuildContext context, {StandingEntry? existing}) {
    final teamCtrl = TextEditingController(text: existing?.teamName ?? '');
    final playedCtrl = TextEditingController(text: '${existing?.played ?? 0}');
    final winsCtrl = TextEditingController(text: '${existing?.wins ?? 0}');
    final lossesCtrl = TextEditingController(text: '${existing?.losses ?? 0}');
    final gameWinsCtrl =
        TextEditingController(text: '${existing?.gameWins ?? 0}');
    final gameLossesCtrl =
        TextEditingController(text: '${existing?.gameLosses ?? 0}');
    final pointsCtrl = TextEditingController(text: '${existing?.points ?? 0}');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AC.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AC.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Add Standing' : 'Edit Standing',
                  style: AT.heading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: teamCtrl,
                  style: const TextStyle(color: AC.textPrimary),
                  decoration: fieldDecor(
                    hint: 'Team name',
                    icon: Icons.group_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: playedCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Played',
                          icon: Icons.sports_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: winsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Wins',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: lossesCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Losses',
                          icon: Icons.trending_down_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pointsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Points',
                          icon: Icons.star_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gameWinsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Game Wins',
                          icon: Icons.add_chart_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: gameLossesCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AC.textPrimary),
                        decoration: fieldDecor(
                          hint: 'Game Losses',
                          icon: Icons.show_chart_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GradButton(
                  label: existing == null ? 'ADD STANDING' : 'SAVE CHANGES',
                  width: double.infinity,
                  icon: Icons.check_rounded,
                  onTap: () {
                    if (existing != null) {
                      existing.teamName = teamCtrl.text.trim();
                      existing.played =
                          int.tryParse(playedCtrl.text.trim()) ?? 0;
                      existing.wins = int.tryParse(winsCtrl.text.trim()) ?? 0;
                      existing.losses =
                          int.tryParse(lossesCtrl.text.trim()) ?? 0;
                      existing.gameWins =
                          int.tryParse(gameWinsCtrl.text.trim()) ?? 0;
                      existing.gameLosses =
                          int.tryParse(gameLossesCtrl.text.trim()) ?? 0;
                      existing.points =
                          int.tryParse(pointsCtrl.text.trim()) ?? 0;
                    } else {
                      tournament.standings.add(
                        StandingEntry(
                          id: 'standing_${DateTime.now().millisecondsSinceEpoch}',
                          teamName: teamCtrl.text.trim(),
                          played: int.tryParse(playedCtrl.text.trim()) ?? 0,
                          wins: int.tryParse(winsCtrl.text.trim()) ?? 0,
                          losses: int.tryParse(lossesCtrl.text.trim()) ?? 0,
                          gameWins: int.tryParse(gameWinsCtrl.text.trim()) ?? 0,
                          gameLosses:
                              int.tryParse(gameLossesCtrl.text.trim()) ?? 0,
                          points: int.tryParse(pointsCtrl.text.trim()) ?? 0,
                        ),
                      );
                    }
                    onChanged();
                    Navigator.pop(context);
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

// ── Redesigned Premium Mobile Card ─────────────────────────────────────────
class _StandingCard extends StatelessWidget {
  final int rank;
  final int total;
  final StandingEntry standing;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const _StandingCard({
    required this.rank,
    required this.total,
    required this.standing,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusIndicatorColor(rank, total);
    final winRate = standing.played > 0
        ? (standing.wins / standing.played * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AC.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal Status Edge Accent Line
                Container(width: 4, color: statusColor),

                // Card Main Body Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Primary identity row
                        Row(
                          children: [
                            // Absolute Compact Rank Number
                            Text(
                              '$rank',
                              style: TextStyle(
                                color: statusColor == Colors.transparent
                                    ? AC.textSecondary
                                    : statusColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Avatar Badge Component
                            AdminLogoBadge(
                              imageUrl: null,
                              fallback: standing.teamName,
                              size: 28,
                              radius: 8,
                              backgroundColor: AC.bg1,
                              borderColor: AC.border,
                              textStyle: const TextStyle(
                                color: AC.cyan,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Team Name Info Text Wrap Layout
                            Expanded(
                              child: Text(
                                standing.teamName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AC.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Clean Points Pill
                            Text(
                              '${standing.points} pts',
                              style: const TextStyle(
                                color: AC.cyan,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Unified Grid Data Summary Layout Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatCell(
                              label: 'MATCHES',
                              value: '${standing.wins}W - ${standing.losses}L',
                              tone: AC.textPrimary,
                            ),
                            _StatCell(
                              label: 'GAMES',
                              value:
                                  '${standing.gameWins}W - ${standing.gameLosses}L',
                              tone: AC.textSecondary,
                            ),
                            _StatCell(
                              label: 'DIFF',
                              value: standing.diff >= 0
                                  ? '+${standing.diff}'
                                  : '${standing.diff}',
                              tone: standing.diff >= 0 ? AC.green : AC.red,
                            ),
                            _StatCell(
                              label: 'WIN RATE',
                              value: '$winRate%',
                              tone: AC.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusIndicatorColor(int rank, int total) {
    if (rank <= 2) return const Color(0xFF00C853); // Top Promotion
    if (rank == 3 || rank == 4) return const Color(0xFFFFA000); // Mid Tier
    if (rank >= total - 1 && total > 4) return AC.red; // Relegation
    return Colors.transparent; // Standard Neutral Class
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _StatCell({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AT.label.copyWith(
            fontSize: 9,
            letterSpacing: 0.5,
            color: AC.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: tone,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
