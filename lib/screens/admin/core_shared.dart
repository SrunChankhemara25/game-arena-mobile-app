import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/backend_service.dart';
import '../../services/media_service.dart';

class AC {
  static const bg0 = Color(0xFF0B0E1A);
  static const bg1 = Color(0xFF101423);
  static const bg2 = Color(0xFF171C2D);
  static const bg3 = Color(0xFF20263A);
  static const bg4 = Color(0xFF2A3148);

  static const pink = Color(0xFFFF168B);
  static const purple = Color(0xFFA414FF);
  static const cyan = Color(0xFF00E5FF);
  static const cyanDeep = Color(0xFF00B8D4);
  static const blue = Color(0xFF5D72FF);
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444);
  static const gold = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);
  static const violet = Color(0xFF8B5CF6);

  static const textPrimary = Color(0xFFF5F7FB);
  static const textSecondary = Color(0xFFB8C6D8);
  static const textMuted = Color(0xFF6B738C);

  static const border = Color(0xFF2B3046);
  static const borderStrong = Color(0xFF383E57);

  static const gradPrimary = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradPrimaryVert = LinearGradient(
    colors: [Color(0xFFFF0F7B), Color(0xFFBC00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradCard = LinearGradient(
    colors: [Color(0xFF191E31), Color(0xFF121624)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradHero = LinearGradient(
    colors: [Color(0xFF14182A), Color(0xFF0B0F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AT {
  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AC.textPrimary,
    height: 1.1,
    letterSpacing: -0.4,
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
    height: 1.55,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AC.textMuted,
    letterSpacing: 1.15,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AC.textMuted,
  );
}

BoxDecoration cardDecor({
  Color? border,
  double radius = 22,
  bool elevated = false,
  Gradient? gradient,
}) =>
    BoxDecoration(
      gradient: gradient ?? AC.gradCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? AC.border, width: 1),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ]
          : null,
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
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AC.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AC.cyan, width: 1.4),
      ),
    );

enum GameCtx {
  mlbb('Mobile Legends', '⚔️'),
  pubg('PUBG Mobile', '🪂'),
  freeFire('Free Fire', '🔥'),
  valorant('Valorant', '🎯'),
  cod('COD Mobile', '💣'),
  eFootball('eFootball', '⚽'),
  other('Other', '🎮');

  final String label;
  final String emoji;
  const GameCtx(this.label, this.emoji);
}

enum TourStatus {
  upcoming('Upcoming'),
  open('Open'),
  live('Live'),
  closed('Closed');

  final String label;
  const TourStatus(this.label);
}

enum ApprovalState {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  final String label;
  const ApprovalState(this.label);
}

enum UserStatus {
  active('Active'),
  suspended('Suspended');

  final String label;
  const UserStatus(this.label);
}

enum TourFormat {
  singleElim('Single Elimination'),
  doubleElim('Double Elimination'),
  groupStage('Group Stage'),
  groupAndElim('Group + Playoffs'),
  roundRobin('Round Robin');

  final String label;
  const TourFormat(this.label);
}

class AppUser {
  final String id;
  String name;
  String email;
  UserStatus status;
  String role;
  String? country;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.status = UserStatus.active,
    this.role = 'Player',
    this.country,
  });
}

class TeamReg {
  final String id;
  String teamName;
  String region;
  List<String> roster;
  String? coach;
  String? assistantCoach;
  String? manager;
  String? note;
  ApprovalState state;

  TeamReg({
    required this.id,
    required this.teamName,
    required this.region,
    required this.roster,
    this.coach,
    this.assistantCoach,
    this.manager,
    this.note,
    this.state = ApprovalState.pending,
  });

  int get lineupCount =>
      roster.where((player) => player.trim().isNotEmpty).toList().length;
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
  String? date;
  String? time;
  String? winner;
  bool isFinalized;

  MatchNode({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.date,
    this.time,
    this.winner,
    this.isFinalized = false,
  });
}

class BracketRound {
  final String id;
  String roundName;
  List<MatchNode> matches;

  BracketRound({
    required this.id,
    required this.roundName,
    required this.matches,
  });
}

class StandingEntry {
  final String id;
  String teamName;
  int played;
  int wins;
  int losses;
  int gameWins;
  int gameLosses;
  int points;

  StandingEntry({
    required this.id,
    required this.teamName,
    required this.played,
    required this.wins,
    required this.losses,
    this.gameWins = 0,
    this.gameLosses = 0,
    required this.points,
  });

  int get diff => gameWins - gameLosses;
}

class Tournament {
  final String id;
  String title;
  GameCtx game;
  String? logoUrl;
  TourStatus status;
  String prize;
  String type;
  TourFormat format;
  String? startDate;
  String? endDate;
  String? regDeadline;
  String? description;
  String? requirements;
  String? organizer;
  String? location;
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
    this.logoUrl,
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
    this.location,
    this.maxTeams = 16,
    this.isArchived = false,
    required this.registrants,
    List<ScheduleEntry>? schedules,
    List<BracketRound>? bracketRounds,
    List<StandingEntry>? standings,
  })  : schedules = schedules ?? [],
        bracketRounds = bracketRounds ?? [],
        standings = standings ?? [];

  int get pendingCount => registrants
      .where((team) => team.state == ApprovalState.pending)
      .toList()
      .length;

  int get approvedCount => registrants
      .where((team) => team.state == ApprovalState.approved)
      .toList()
      .length;

  int get spotsLeft => maxTeams - registrants.length;

  String? get resolvedLogoUrl => logoUrl ?? defaultGameLogoUrl(game);
}

class DB {
  static List<AppUser> users = [];

  static List<Tournament> tournaments = [];

  static bool _initialized = false;

  static Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) return;
    await BackendService.instance.bootstrap();
    await refresh();
    _initialized = true;
  }

  static Future<void> refresh() async {
    final userProfiles = await BackendService.instance.getUsers();
    final tournamentModels = await BackendService.instance.getTournaments();

    users = userProfiles
        .where(_isVisibleUserProfile)
        .map(_userFromProfile)
        .toList();
    tournaments = tournamentModels.map(_tournamentFromModel).toList();
  }

  static Future<void> saveTournament(Tournament tournament) async {
    final previous = await BackendService.instance.getTournament(tournament.id);
    final model = _modelFromTournament(tournament, previous: previous);
    await BackendService.instance.saveTournament(model);
    await refresh();
  }

  static Future<void> deleteTournament(String tournamentId) async {
    await BackendService.instance.deleteTournament(tournamentId);
    await refresh();
  }

  static Future<void> setTournamentArchived(
      String tournamentId, bool isArchived) async {
    await BackendService.instance
        .setTournamentArchived(tournamentId, isArchived);
    await refresh();
  }

  static Future<void> updateTeamApproval({
    required String tournamentId,
    required String teamId,
    required ApprovalState state,
  }) async {
    await BackendService.instance.updateTeamApproval(
      tournamentId: tournamentId,
      teamId: teamId,
      status: _teamStatusFromApproval(state),
    );
    await refresh();
  }

  static Future<void> updateUser(AppUser user) async {
    final existing = await BackendService.instance.getUserProfile(user.email);
    if (existing == null) return;
    await BackendService.instance.saveUserProfile(
      existing.copyWith(
        name: user.name,
        country: user.country,
        role: _roleFromLabel(user.role),
        status: user.status == UserStatus.suspended ? 'suspended' : 'active',
      ),
    );
    await refresh();
  }

  static Future<void> deleteUser(String email) async {
    await BackendService.instance.deleteUser(email);
    await refresh();
  }

  static Future<void> sendBroadcast({
    required String title,
    required String message,
    String? email,
  }) async {
    await BackendService.instance.sendBroadcast(
      title: title,
      message: message,
      targetEmail: email,
    );
  }

  /// Save a broadcast record so history persists across sessions.
  static Future<void> saveBroadcastRecord(BroadcastRecord record) async {
    await BackendService.instance.saveBroadcastRecord(record);
  }

  /// Delete a broadcast history record by id.
  static Future<void> deleteBroadcastRecord(String id) async {
    await BackendService.instance.deleteBroadcastRecord(id);
  }

  static Future<void> archiveBroadcastRecord(String id, bool archived) async {
    await BackendService.instance.archiveBroadcastRecord(id, archived);
  }

  /// Fetch all past broadcast records (newest first).
  static Future<List<BroadcastRecord>> getBroadcastHistory() async {
    return BackendService.instance.getBroadcastHistory();
  }

  /// Real-time stream of broadcast history.
  static Stream<List<BroadcastRecord>> watchBroadcastHistory() {
    return BackendService.instance.watchBroadcastHistory();
  }

  /// Real-time stream of all users — use in StreamBuilder for live updates.
  static Stream<List<AppUser>> watchUsers() {
    return BackendService.instance.watchUsers().map(
          (profiles) => profiles
              .where(_isVisibleUserProfile)
              .map(_userFromProfile)
              .toList(),
        );
  }

  /// Real-time stream of all tournaments — use in StreamBuilder for live updates.
  static Stream<List<Tournament>> watchTournaments() {
    return BackendService.instance.watchTournaments().map(
          (models) => models.map(_tournamentFromModel).toList(),
        );
  }

  static AppUser _userFromProfile(UserModel user) {
    return AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role.label,
      country: user.country,
      status:
          user.status == 'suspended' ? UserStatus.suspended : UserStatus.active,
    );
  }

  static bool _isVisibleUserProfile(UserModel user) {
    return user.role != UserRole.admin;
  }

  static Tournament _tournamentFromModel(TournamentModel model) {
    final registrants = model.teams.map((team) {
      return TeamReg(
        id: team.id,
        teamName: team.name,
        region: team.country ?? 'Global',
        roster: team.players.map((player) => player.ign).toList(),
        coach: team.coachName?.isNotEmpty == true
            ? team.coachName
            : _firstPlayerName(team, PlayerType.coach),
        assistantCoach: team.assistantCoachName?.isNotEmpty == true
            ? team.assistantCoachName
            : _firstPlayerName(team, PlayerType.assistantCoach),
        manager: team.managerName ?? team.founderName,
        note: team.description,
        state: _approvalFromTeamStatus(team.status),
      );
    }).toList();

    final schedules = model.scheduleEntries
        .map(
          (match) => ScheduleEntry(
            id: match.id,
            round: match.round,
            teamA: _teamNameForId(model, match.team1Id),
            teamB: _teamNameForId(model, match.team2Id),
            date: _datePart(match.scheduledAt),
            time: _timePart(match.scheduledAt),
            venue: match.venue,
          ),
        )
        .toList();

    final bracketRounds = <BracketRound>[];
    final grouped = <String, List<MatchModel>>{};
    for (final match in model.bracketEntries) {
      grouped.putIfAbsent(match.round, () => []).add(match);
    }
    grouped.forEach((round, matches) {
      bracketRounds.add(
        BracketRound(
          id: 'round_${round.hashCode}',
          roundName: round,
          matches: matches
              .map(
                (match) => MatchNode(
                  id: match.id,
                  teamA: _teamNameForId(model, match.team1Id),
                  teamB: _teamNameForId(model, match.team2Id),
                  scoreA: match.score1,
                  scoreB: match.score2,
                  date: _datePart(match.scheduledAt),
                  time: _timePart(match.scheduledAt),
                  winner: match.winnerId?.trim().isNotEmpty == true
                      ? _teamNameForId(model, match.winnerId)
                      : null,
                  isFinalized: match.status == 'completed',
                ),
              )
              .toList(),
        ),
      );
    });

    final standings = model.standings
        .map(
          (standing) => StandingEntry(
            id: standing.teamId,
            teamName: standing.teamName,
            played: standing.played,
            wins: standing.wins,
            losses: standing.losses,
            points: standing.points,
            gameWins: standing.wins,
            gameLosses: standing.losses,
          ),
        )
        .toList();

    return Tournament(
      id: model.id,
      title: model.title,
      game: _gameCtxFromTitle(model.game),
      logoUrl: model.logoUrl,
      status: _tourStatusFromModel(model),
      prize: model.prizePoolDisplay,
      type: model.type,
      format: _tourFormatFromModel(model.format),
      startDate: model.startDate?.toIso8601String().split('T').first,
      endDate: model.endDate?.toIso8601String().split('T').first,
      regDeadline:
          model.registrationDeadline?.toIso8601String().split('T').first,
      description: model.description,
      requirements: model.requirements,
      organizer: model.organizer,
      location: model.location,
      maxTeams: model.maxTeams,
      isArchived: model.isArchived,
      registrants: registrants,
      schedules: schedules,
      bracketRounds: bracketRounds,
      standings: standings,
    );
  }

  static TournamentModel _modelFromTournament(
    Tournament tournament, {
    TournamentModel? previous,
  }) {
    final previousTeams = {
      for (final team in previous?.teams ?? <TeamModel>[]) team.id: team
    };
    final teams = tournament.registrants.map((registration) {
      final existing = previousTeams[registration.id];
      final existingPlayers = {
        for (final player in existing?.players ?? <PlayerModel>[])
          player.ign.trim().toLowerCase(): player
      };
      final players = registration.roster.map((name) {
        final key = name.trim().toLowerCase();
        final previousPlayer = existingPlayers[key];
        if (previousPlayer != null) {
          return PlayerModel(
            id: previousPlayer.id,
            ign: name,
            realName: previousPlayer.realName,
            avatarUrl: previousPlayer.avatarUrl,
            type: previousPlayer.type,
            teamId: previousPlayer.teamId,
            game: _gameTitleFromCtx(tournament.game),
            contactInfo: previousPlayer.contactInfo,
            fullName: previousPlayer.fullName,
            role: previousPlayer.role,
            nationality: previousPlayer.nationality,
            jerseyNumber: previousPlayer.jerseyNumber,
            gameUID: previousPlayer.gameUID,
            idType: previousPlayer.idType,
            dob: previousPlayer.dob,
          );
        }
        return PlayerModel(
          id: '${registration.id}_${name.hashCode}',
          ign: name,
          type: PlayerType.main,
          game: _gameTitleFromCtx(tournament.game),
        );
      }).toList();
      return (existing ??
              TeamModel(
                id: registration.id,
                name: registration.teamName,
                game: _gameTitleFromCtx(tournament.game),
              ))
          .copyWith(
        name: registration.teamName,
        country: registration.region,
        players: players,
        description: registration.note,
        managerName: registration.manager,
        founderName: registration.manager,
        coachName: registration.coach,
        assistantCoachName: registration.assistantCoach,
        status: _teamStatusFromApproval(registration.state),
      );
    }).toList();

    final teamByName = <String, String>{};
    for (final team in teams) {
      teamByName[team.id.trim().toLowerCase()] = team.id;
      teamByName[team.name.trim().toLowerCase()] = team.id;
    }
    String teamIdFor(String value) =>
        teamByName[value.trim().toLowerCase()] ?? value;

    final scheduleMatches = <MatchModel>[];
    for (final schedule in tournament.schedules) {
      scheduleMatches.add(
        MatchModel(
          id: schedule.id,
          tournamentId: tournament.id,
          team1Id: teamIdFor(schedule.teamA),
          team2Id: teamIdFor(schedule.teamB),
          round: schedule.round,
          status: 'upcoming',
          scheduledAt:
              '${schedule.date}${schedule.time.isNotEmpty ? ' • ${schedule.time}' : ''}',
          venue: schedule.venue,
        ),
      );
    }
    final bracketMatches = <MatchModel>[];
    for (final round in tournament.bracketRounds) {
      for (final match in round.matches) {
        bracketMatches.add(
          MatchModel(
            id: match.id,
            tournamentId: tournament.id,
            team1Id: teamIdFor(match.teamA),
            team2Id: teamIdFor(match.teamB),
            score1: match.scoreA,
            score2: match.scoreB,
            round: round.roundName,
            status: match.isFinalized ? 'completed' : 'upcoming',
            winnerId: match.winner?.trim().isNotEmpty == true
                ? teamIdFor(match.winner!)
                : null,
            scheduledAt:
                '${match.date ?? ''}${match.time?.isNotEmpty == true ? ' • ${match.time}' : ''}'
                    .trim(),
          ),
        );
      }
    }

    final standings = tournament.standings
        .map(
          (standing) => StandingModel(
            teamId: teamIdFor(standing.teamName),
            teamName: standing.teamName,
            played: standing.played,
            wins: standing.wins,
            losses: standing.losses,
            points: standing.points,
          ),
        )
        .toList();
    final standingByTeam = <String, StandingModel>{};
    for (final standing in standings) {
      standingByTeam[standing.teamId.trim().toLowerCase()] = standing;
      standingByTeam[standing.teamName.trim().toLowerCase()] = standing;
    }
    final syncedTeams = teams.map((team) {
      final standing = standingByTeam[team.id.trim().toLowerCase()] ??
          standingByTeam[team.name.trim().toLowerCase()];
      if (standing == null) return team;
      return team.copyWith(wins: standing.wins, losses: standing.losses);
    }).toList();

    return (previous ??
            TournamentModel(
              id: tournament.id,
              title: tournament.title,
              game: _gameTitleFromCtx(tournament.game),
              status: _modelStatusFromTour(tournament.status),
            ))
        .copyWith(
      title: tournament.title,
      game: _gameTitleFromCtx(tournament.game),
      status: _modelStatusFromTour(tournament.status),
      format: _modelFormatFromTour(tournament.format),
      description: tournament.description,
      prizePool: _parsePrize(tournament.prize),
      maxTeams: tournament.maxTeams,
      registeredTeams: syncedTeams.length,
      matches: [...scheduleMatches, ...bracketMatches],
      scheduleMatches: scheduleMatches,
      bracketMatches: bracketMatches,
      teams: syncedTeams,
      standings: standings,
      startDate: _parseDate(tournament.startDate),
      endDate: _parseDate(tournament.endDate),
      organizer: tournament.organizer,
      location: tournament.location,
      registrationDeadline: _parseDate(tournament.regDeadline),
      logoUrl: tournament.logoUrl,
      type: tournament.type,
      requirements: tournament.requirements,
      isArchived: tournament.isArchived,
    );
  }

  static String? _firstPlayerName(TeamModel team, PlayerType type) {
    final player =
        team.players.where((entry) => entry.type == type).firstOrNull;
    return player?.fullName ?? player?.ign;
  }

  static String _teamNameForId(TournamentModel tournament, String? teamId) {
    if (teamId == null || teamId.isEmpty) return 'TBD';
    final key = teamId.trim().toLowerCase();
    return tournament.teams
            .where((team) =>
                team.id.trim().toLowerCase() == key ||
                team.name.trim().toLowerCase() == key)
            .firstOrNull
            ?.name ??
        teamId;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  static int? _parsePrize(String prize) {
    final digits = prize.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static String _datePart(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.split('•').first.trim();
  }

  static String _timePart(String? value) {
    if (value == null || !value.contains('•')) return '';
    return value.split('•').last.trim();
  }

  static ApprovalState _approvalFromTeamStatus(TeamStatus status) {
    switch (status) {
      case TeamStatus.approved:
        return ApprovalState.approved;
      case TeamStatus.rejected:
        return ApprovalState.rejected;
      case TeamStatus.pending:
        return ApprovalState.pending;
    }
  }

  static TeamStatus _teamStatusFromApproval(ApprovalState state) {
    switch (state) {
      case ApprovalState.approved:
        return TeamStatus.approved;
      case ApprovalState.rejected:
        return TeamStatus.rejected;
      case ApprovalState.pending:
        return TeamStatus.pending;
    }
  }

  static TourStatus _tourStatusFromModel(TournamentModel model) {
    if (model.isArchived) return TourStatus.closed;
    switch (model.status) {
      case TournamentStatus.ongoing:
        return TourStatus.live;
      case TournamentStatus.registration:
        return TourStatus.open;
      case TournamentStatus.upcoming:
        return TourStatus.upcoming;
      case TournamentStatus.ended:
        return TourStatus.closed;
    }
  }

  static TournamentStatus _modelStatusFromTour(TourStatus status) {
    switch (status) {
      case TourStatus.live:
        return TournamentStatus.ongoing;
      case TourStatus.open:
        return TournamentStatus.registration;
      case TourStatus.upcoming:
        return TournamentStatus.upcoming;
      case TourStatus.closed:
        return TournamentStatus.ended;
    }
  }

  static TourFormat _tourFormatFromModel(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.singleElim:
        return TourFormat.singleElim;
      case TournamentFormat.doubleElim:
        return TourFormat.doubleElim;
      case TournamentFormat.groupStage:
        return TourFormat.groupStage;
      case TournamentFormat.groupAndElim:
        return TourFormat.groupAndElim;
      case TournamentFormat.roundRobin:
        return TourFormat.roundRobin;
    }
  }

  static TournamentFormat _modelFormatFromTour(TourFormat format) {
    switch (format) {
      case TourFormat.singleElim:
        return TournamentFormat.singleElim;
      case TourFormat.doubleElim:
        return TournamentFormat.doubleElim;
      case TourFormat.groupStage:
        return TournamentFormat.groupStage;
      case TourFormat.groupAndElim:
        return TournamentFormat.groupAndElim;
      case TourFormat.roundRobin:
        return TournamentFormat.roundRobin;
    }
  }

  static GameCtx _gameCtxFromTitle(GameTitle game) {
    switch (game) {
      case GameTitle.mlbb:
        return GameCtx.mlbb;
      case GameTitle.pubg:
        return GameCtx.pubg;
      case GameTitle.freeFire:
        return GameCtx.freeFire;
      case GameTitle.valorant:
        return GameCtx.valorant;
      case GameTitle.cod:
        return GameCtx.cod;
      case GameTitle.eFootball:
        return GameCtx.eFootball;
      case GameTitle.other:
        return GameCtx.other;
    }
  }

  static GameTitle _gameTitleFromCtx(GameCtx game) {
    switch (game) {
      case GameCtx.mlbb:
        return GameTitle.mlbb;
      case GameCtx.pubg:
        return GameTitle.pubg;
      case GameCtx.freeFire:
        return GameTitle.freeFire;
      case GameCtx.valorant:
        return GameTitle.valorant;
      case GameCtx.cod:
        return GameTitle.cod;
      case GameCtx.eFootball:
        return GameTitle.eFootball;
      case GameCtx.other:
        return GameTitle.other;
    }
  }

  static UserRole _roleFromLabel(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return UserRole.admin;
    if (lower.contains('organizer') || lower.contains('manager')) {
      return UserRole.organizer;
    }
    return UserRole.user;
  }
}

Color approvalColor(ApprovalState state) => switch (state) {
      ApprovalState.pending => AC.gold,
      ApprovalState.approved => AC.green,
      ApprovalState.rejected => AC.red,
    };

Color tourStatusColor(TourStatus status) => switch (status) {
      TourStatus.upcoming => AC.cyan,
      TourStatus.open => AC.green,
      TourStatus.live => AC.orange,
      TourStatus.closed => AC.textMuted,
    };

Color userStatusColor(UserStatus status) => switch (status) {
      UserStatus.active => AC.green,
      UserStatus.suspended => AC.red,
    };

String? defaultGameLogoUrl(GameCtx game) => switch (game) {
      GameCtx.mlbb =>
        'https://upload.wikimedia.org/wikipedia/en/thumb/9/90/Mobile_Legends_Bang_Bang_logo.png/320px-Mobile_Legends_Bang_Bang_logo.png',
      GameCtx.pubg =>
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/PUBG_Mobile_logo.svg/320px-PUBG_Mobile_logo.svg.png',
      GameCtx.freeFire =>
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Garena_Free_Fire_logo.svg/320px-Garena_Free_Fire_logo.svg.png',
      GameCtx.valorant =>
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Valorant_logo_-_pink_color_version.svg/320px-Valorant_logo_-_pink_color_version.svg.png',
      GameCtx.cod =>
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Call_of_Duty_Mobile_logo.svg/320px-Call_of_Duty_Mobile_logo.svg.png',
      GameCtx.eFootball =>
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/EFootball_logo.svg/320px-EFootball_logo.svg.png',
      GameCtx.other => null,
    };

String compactInitials(String value, {int maxChars = 2}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first
        .substring(0, math.min(parts.first.length, maxChars))
        .toUpperCase();
  }
  return parts
      .take(maxChars)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();
}

class GradButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final IconData? icon;

  const GradButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 50,
        decoration: BoxDecoration(
          gradient: AC.gradPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AC.purple.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLogoBadge extends StatelessWidget {
  final String? imageUrl;
  final String fallback;
  final double size;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  const AdminLogoBadge({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.size = 52,
    this.radius = 16,
    this.backgroundColor,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFallback = compactInitials(fallback);
    final bg = backgroundColor ?? AC.bg3;
    final border = borderColor ?? AC.border;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: _AdminLogoImage(
          imageUrl: imageUrl,
          fallback: resolvedFallback,
          textStyle: textStyle,
        ),
      ),
    );
  }
}

class _AdminLogoImage extends StatelessWidget {
  final String? imageUrl;
  final String fallback;
  final TextStyle? textStyle;

  const _AdminLogoImage({
    required this.imageUrl,
    required this.fallback,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = MediaService.imageProviderFor(imageUrl);
    if (provider == null) {
      return _FallbackLogo(fallback: fallback, textStyle: textStyle);
    }

    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _FallbackLogo(fallback: fallback, textStyle: textStyle),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final String fallback;
  final TextStyle? textStyle;

  const _FallbackLogo({
    required this.fallback,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AC.gradCard),
      child: Center(
        child: Text(
          fallback,
          style: textStyle ??
              const TextStyle(
                color: AC.cyan,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}

class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const OutlineBtn({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tone = color ?? AC.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: tone.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tone.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: tone,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AT.label.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class SectionHdr extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHdr({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: AC.gradPrimaryVert,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AT.label.copyWith(color: AC.textSecondary),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: AT.caption.copyWith(color: AC.cyan),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AC.bg3,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AC.border),
              ),
              child: Icon(icon, color: AC.cyan, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title, style: AT.heading, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AT.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  Color confirmColor = AC.red,
  IconData icon = Icons.warning_amber_rounded,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AC.bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: confirmColor.withOpacity(0.28)),
                  ),
                  child: Icon(icon, color: confirmColor, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: AT.heading.copyWith(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AT.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlineBtn(
                        label: 'Cancel',
                        color: AC.textSecondary,
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlineBtn(
                        label: confirmLabel,
                        color: confirmColor,
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}
