import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../widgets/common/widgets.dart';
import '../tournament/tournament_detail_screen.dart';
import '../profile/profile_screen.dart'; // ← adjust path to match your project structure

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchController = TextEditingController();
  final PageController _featuredDeckController =
      PageController(viewportFraction: 0.86);

  GameTitle? activeGameFilter;
  TournamentStatus? activeStatusFilter;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _featuredDeckController.dispose();
    super.dispose();
  }

  List<TournamentModel> get filteredTournaments {
    var list = MockData.tournaments;

    if (activeGameFilter != null) {
      list = list.where((t) => t.game == activeGameFilter).toList();
    }
    if (activeStatusFilter != null) {
      list = list.where((t) => t.status == activeStatusFilter).toList();
    }

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(query);
        final orgMatch = (t.organizer ?? '').toLowerCase().contains(query);
        final gameMatch = t.game.label.toLowerCase().contains(query);
        return titleMatch || orgMatch || gameMatch;
      }).toList();
    }

    return list;
  }

  void _handleFilterUpdate(VoidCallback updateFn) {
    HapticFeedback.selectionClick();
    setState(updateFn);
  }

  /// Navigate to ProfileScreen. Pass [scrollToAlerts] true to jump to alerts.
  void _navigateToProfile({required bool scrollToAlerts}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(scrollToAlerts: scrollToAlerts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTournaments = filteredTournaments;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildPremiumAmbientGlows(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicHeaderSystem(),
                  const SizedBox(height: 16),
                  _buildHorizontalPillFilters(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      children: [
                        _buildEliteTournamentsDeckSection(displayTournaments),
                        const SizedBox(height: 28),
                        _buildDiscoverMoreSection(displayTournaments),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0, right: 8.0),
        child: _buildGlowingJoinActionButton(displayTournaments),
      ),
    );
  }

  Widget _buildPremiumAmbientGlows() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.cyan.withOpacity(0.08),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeaderSystem() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isSearchActive
          ? _buildActiveNeonSearchBar()
          : _buildDefaultProfileHeader(),
    );
  }

  Widget _buildDefaultProfileHeader() {
    return Padding(
      key: const ValueKey('DefaultProfileHeader'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // ── Tappable avatar → ProfileScreen ──────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _navigateToProfile(scrollToAlerts: false);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bg1,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.magenta, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Tappable name/tier row → ProfileScreen ───────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToProfile(scrollToAlerts: false);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vortex_Striker',
                      style: AppText.heading
                          .copyWith(fontSize: 16, letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('PRO LEAGUE TIER',
                          style: AppText.caption.copyWith(
                              color: AppColors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bell icon → ProfileScreen scrolled to Alerts ─────────────
          _buildHeaderIconButton(Icons.notifications_none_rounded, () {
            HapticFeedback.lightImpact();
            _navigateToProfile(scrollToAlerts: true);
          }),
          const SizedBox(width: 10),

          // ── Search icon → inline search bar ──────────────────────────
          _buildHeaderIconButton(Icons.search_rounded, () {
            HapticFeedback.lightImpact();
            setState(() => _isSearchActive = true);
          }),
        ],
      ),
    );
  }

  Widget _buildActiveNeonSearchBar() {
    return Padding(
      key: const ValueKey('ActiveNeonSearchBar'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cyan, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.cyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (_) => setState(() {}),
                cursorColor: AppColors.cyan,
                decoration: const InputDecoration(
                  hintText: 'Search tournaments...',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 14),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                searchController.clear();
                setState(() => _isSearchActive = false);
              },
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildHorizontalPillFilters() {
    final List<Map<String, dynamic>> structuralFilters = [
      {'label': 'All', 'game': null, 'status': null},
      {
        'label': 'Reg. Open',
        'game': null,
        'status': TournamentStatus.registration
      },
      ...GameTitle.values
          .map((g) => {'label': g.label, 'game': g, 'status': null}),
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: structuralFilters.length,
        itemBuilder: (context, index) {
          final filter = structuralFilters[index];

          bool isSelected = false;
          if (index == 0) {
            isSelected = activeGameFilter == null && activeStatusFilter == null;
          } else if (filter['status'] != null) {
            isSelected = activeStatusFilter == filter['status'];
          } else {
            isSelected = activeGameFilter == filter['game'];
          }

          return GestureDetector(
            onTap: () => _handleFilterUpdate(() {
              if (index == 0) {
                activeGameFilter = null;
                activeStatusFilter = null;
              } else if (filter['status'] != null) {
                activeStatusFilter = activeStatusFilter == filter['status']
                    ? null
                    : filter['status'];
                activeGameFilter = null;
              } else {
                activeGameFilter =
                    activeGameFilter == filter['game'] ? null : filter['game'];
                activeStatusFilter = null;
              }
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.magenta : AppColors.bg1,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                filter['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEliteTournamentsDeckSection(List<TournamentModel> tournaments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Elite Tournaments',
                  style: AppText.heading.copyWith(fontSize: 18)),
              Text('VIEW ALL',
                  style: const TextStyle(
                      color: AppColors.magenta,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SrxCardsDisplay(
            tournaments: tournaments,
            featuredDeckController: _featuredDeckController),
      ],
    );
  }

  Widget _buildDiscoverMoreSection(List<TournamentModel> tournaments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discover More', style: AppText.heading.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          if (tournaments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No active tournaments available.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tournaments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final t = tournaments[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TournamentDetailScreen(tournament: t)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration:
                        AppDecorations.glowCard(glowColor: AppColors.bg0),
                    child: Row(
                      children: [
                        // Game emoji icon box
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: AppColors.bg3,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border)),
                          child: Center(
                              child: Text(t.game.emoji,
                                  style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 14),
                        // Title, badges, date/prize
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                StatusBadge(status: t.status),
                                const SizedBox(width: 6),
                                GameBadge(game: t.game, small: true),
                              ]),
                              const SizedBox(height: 5),
                              Text(
                                t.title,
                                style: AppText.heading.copyWith(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${t.startDateDisplay} • ${t.prizePoolDisplay}',
                                style: AppText.caption,
                              ),
                            ],
                          ),
                        ),
                        // Team count
                        Column(
                          children: [
                            Text(
                              '${t.registeredTeams}/${t.maxTeams}',
                              style: AppText.bodyMd
                                  .copyWith(color: AppColors.cyan),
                            ),
                            Text('teams', style: AppText.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGlowingJoinActionButton(List<TournamentModel> tournaments) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          backgroundColor: AppColors.magenta,
          elevation: 8,
          shape: const CircleBorder(),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (tournaments.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TournamentDetailScreen(tournament: tournaments.first),
                ),
              );
            }
          },
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
        Positioned(
          top: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.cyan, borderRadius: BorderRadius.circular(6)),
          ),
        )
      ],
    );
  }
}

class SrxCardsDisplay extends StatelessWidget {
  final List<TournamentModel> tournaments;
  final PageController featuredDeckController;

  const SrxCardsDisplay(
      {super.key,
      required this.tournaments,
      required this.featuredDeckController});

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No tournaments match parameters.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: PageView.builder(
        controller: featuredDeckController,
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final t = tournaments[index];
          final isLive = t.status == TournamentStatus.ongoing;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TournamentDetailScreen(tournament: t)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
                image: t.bannerUrl != null
                    ? DecorationImage(
                        image: NetworkImage(t.bannerUrl!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            AppColors.bg1.withOpacity(0.75), BlendMode.srcOver),
                      )
                    : null,
                gradient: t.bannerUrl == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.bg1, AppColors.bg1.withOpacity(0.6)],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? AppColors.red : AppColors.magenta,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLive ? 'LIVE NOW' : 'FEATURED',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Spacer(),
                  Text(t.title,
                      style: AppText.heading.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(t.prizePoolDisplay,
                      style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
