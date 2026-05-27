import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/backend_service.dart';
import '../../widgets/common/widgets.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});
  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

// REMOVED SingleTickerProviderStateMixin — DefaultTabController handles this now!
class _TournamentsScreenState extends State<TournamentsScreen> {
  final _search = TextEditingController();
  GameTitle? _gameFilter;

  // No more manual TabController to initialize!

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TournamentModel> _getFiltered(
      List<TournamentModel> tournaments, TournamentStatus? status) {
    var list = List<TournamentModel>.from(tournaments);
    if (status != null) list = list.where((t) => t.status == status).toList();
    if (_gameFilter != null) {
      list = list.where((t) => t.game == _gameFilter).toList();
    }
    if (_search.text.isNotEmpty) {
      list = list
          .where(
              (t) => t.title.toLowerCase().contains(_search.text.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TournamentModel>>(
      stream: BackendService.instance.watchTournaments(),
      builder: (context, snapshot) {
        final tournaments = snapshot.data ?? const <TournamentModel>[];

        // ── FIX: Wrapping the Scaffold in DefaultTabController prevents Hot Reload crashes! ──
        return DefaultTabController(
          length: 4, // Exactly 4 tabs
          child: Scaffold(
            backgroundColor: AppColors.bg0,
            appBar: AppBar(
              backgroundColor: AppColors.bg0,
              title: Text('TOURNAMENTS',
                  style: AppText.heading.copyWith(letterSpacing: 1)),
              actions: [
                IconButton(
                    icon: const Icon(Icons.filter_list_rounded,
                        color: AppColors.textSecondary),
                    onPressed: _showFilterSheet),
              ],
              bottom: TabBar(
                // controller: _tab, <-- Removed! DefaultTabController links it automatically.
                indicatorColor: AppColors.cyan,
                labelStyle:
                    AppText.btnSm.copyWith(color: AppColors.cyan, fontSize: 12),
                unselectedLabelStyle: AppText.btnSm
                    .copyWith(color: AppColors.textMuted, fontSize: 12),
                tabs: const [
                  Tab(text: 'ALL'),
                  Tab(text: 'LIVE'),
                  Tab(text: 'OPEN'),
                  Tab(text: 'UPCOMING'),
                ],
              ),
            ),
            body: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppSearchBar(
                      controller: _search,
                      hint: 'Search tournaments...',
                      onChanged: (_) => setState(() {}))),
              Expanded(
                child: TabBarView(
                  // controller: _tab, <-- Removed! DefaultTabController links it automatically.
                  children: [
                    _TournamentList(
                        tournaments: _getFiltered(tournaments, null)),
                    _TournamentList(
                        tournaments: _getFiltered(
                            tournaments, TournamentStatus.ongoing)),
                    _TournamentList(
                        tournaments: _getFiltered(
                            tournaments, TournamentStatus.registration)),
                    _TournamentList(
                        tournaments: _getFiltered(
                            tournaments, TournamentStatus.upcoming)),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showFilterSheet() => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bg1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('FILTER BY GAME', style: AppText.heading),
                  const Spacer(),
                  if (_gameFilter != null)
                    GestureDetector(
                        onTap: () {
                          setState(() => _gameFilter = null);
                          Navigator.pop(context);
                        },
                        child: Text('Clear',
                            style:
                                AppText.body.copyWith(color: AppColors.cyan))),
                ]),
                const SizedBox(height: 16),
                Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: GameTitle.values
                        .map((g) => GestureDetector(
                              onTap: () {
                                setState(() => _gameFilter = g);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _gameFilter == g
                                      ? AppColors.cyan.withOpacity(0.15)
                                      : AppColors.bg3,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _gameFilter == g
                                          ? AppColors.cyan
                                          : AppColors.border),
                                ),
                                child: Text('${g.emoji} ${g.label}',
                                    style: AppText.bodyMd.copyWith(
                                        color: _gameFilter == g
                                            ? AppColors.cyan
                                            : AppColors.textSecondary)),
                              ),
                            ))
                        .toList()),
                const SizedBox(height: 20),
              ]),
        ),
      );
}

class _TournamentList extends StatelessWidget {
  final List<TournamentModel> tournaments;
  const _TournamentList({required this.tournaments});

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return const EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No Tournaments',
          subtitle: 'No tournaments available in this category');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final t = tournaments[i];
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TournamentDetailScreen(tournament: t))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.glowCard(glowColor: AppColors.bg0),
            child: Row(children: [
              Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border)),
                  child: Center(
                      child: Text(t.game.emoji,
                          style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      StatusBadge(status: t.status),
                      const SizedBox(width: 6),
                      GameBadge(game: t.game, small: true)
                    ]),
                    const SizedBox(height: 5),
                    Text(t.title,
                        style: AppText.heading.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${t.startDateDisplay} • ${t.prizePoolDisplay}',
                        style: AppText.caption),
                  ])),
              Column(children: [
                Text('${t.registeredTeams}/${t.maxTeams}',
                    style: AppText.bodyMd.copyWith(color: AppColors.cyan)),
                Text('teams', style: AppText.caption),
              ]),
            ]),
          ),
        );
      },
    );
  }
}
