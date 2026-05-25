// lib/models/models.dart

// ─── Tournament Status ────────────────────────────────────────────────────────
enum TournamentStatus {
  ongoing,
  registration,
  upcoming,
  ended;

  String get label {
    switch (this) {
      case TournamentStatus.ongoing:      return 'LIVE';
      case TournamentStatus.registration: return 'OPEN';
      case TournamentStatus.upcoming:     return 'SOON';
      case TournamentStatus.ended:        return 'ENDED';
    }
  }
}

// ─── Team Status ──────────────────────────────────────────────────────────────
enum TeamStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case TeamStatus.pending:  return 'PENDING';
      case TeamStatus.approved: return 'APPROVED';
      case TeamStatus.rejected: return 'REJECTED';
    }
  }
}

// ─── Tournament Format ────────────────────────────────────────────────────────
enum TournamentFormat {
  singleElim,
  doubleElim,
  groupStage,
  groupAndElim,
  roundRobin;

  String get label {
    switch (this) {
      case TournamentFormat.singleElim:   return 'Single Elim';
      case TournamentFormat.doubleElim:   return 'Double Elim';
      case TournamentFormat.groupStage:   return 'Group Stage';
      case TournamentFormat.groupAndElim: return 'Group + Playoffs';
      case TournamentFormat.roundRobin:   return 'Round Robin';
    }
  }
}

// ─── Game Title ───────────────────────────────────────────────────────────────
enum GameTitle {
  mlbb,
  pubg,
  freeFire,
  valorant,
  cod,
  eFootball,
  other;

  String get label {
    switch (this) {
      case GameTitle.mlbb:      return 'MLBB';
      case GameTitle.pubg:      return 'PUBG';
      case GameTitle.freeFire:  return 'Free Fire';
      case GameTitle.valorant:  return 'Valorant';
      case GameTitle.cod:       return 'COD Mobile';
      case GameTitle.eFootball: return 'eFootball';
      case GameTitle.other:     return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case GameTitle.mlbb:      return '⚔️';
      case GameTitle.pubg:      return '🪖';
      case GameTitle.freeFire:  return '🔥';
      case GameTitle.valorant:  return '🎯';
      case GameTitle.cod:       return '💣';
      case GameTitle.eFootball: return '⚽';
      case GameTitle.other:     return '🎮';
    }
  }
}

// ─── Player Type ──────────────────────────────────────────────────────────────
enum PlayerType {
  main,
  substitute,
  coach,
  assistantCoach;

  String get label {
    switch (this) {
      case PlayerType.main:           return 'Main';
      case PlayerType.substitute:     return 'Substitute';
      case PlayerType.coach:          return 'Coach';
      case PlayerType.assistantCoach: return 'Asst. Coach';
    }
  }
}

// ─── Player Model ─────────────────────────────────────────────────────────────
class PlayerModel {
  final String id;
  final String ign;
  final String? realName;
  final String? avatarUrl;
  final PlayerType type;
  final String? teamId;
  final GameTitle? game;
  final String? contactInfo;
  // Extended fields
  final String? fullName;
  final String? role;
  final String? nationality;
  final int? jerseyNumber;
  final String? gameUID;
  final String? idType;
  final String? dob;

  const PlayerModel({
    required this.id,
    required this.ign,
    this.realName,
    this.avatarUrl,
    required this.type,
    this.teamId,
    this.game,
    this.contactInfo,
    this.fullName,
    this.role,
    this.nationality,
    this.jerseyNumber,
    this.gameUID,
    this.idType,
    this.dob,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'ign': ign, 'realName': realName, 'avatarUrl': avatarUrl,
    'type': type.name, 'teamId': teamId, 'game': game?.name, 'contactInfo': contactInfo,
    'fullName': fullName, 'role': role, 'nationality': nationality,
    'jerseyNumber': jerseyNumber, 'gameUID': gameUID, 'idType': idType, 'dob': dob,
  };

  factory PlayerModel.fromMap(Map<String, dynamic> map) => PlayerModel(
    id: map['id'] ?? '', ign: map['ign'] ?? '', realName: map['realName'],
    avatarUrl: map['avatarUrl'],
    type: PlayerType.values.firstWhere((t) => t.name == map['type'], orElse: () => PlayerType.main),
    teamId: map['teamId'],
    game: map['game'] != null ? GameTitle.values.firstWhere((g) => g.name == map['game'], orElse: () => GameTitle.other) : null,
    contactInfo: map['contactInfo'],
    fullName: map['fullName'], role: map['role'], nationality: map['nationality'],
    jerseyNumber: map['jerseyNumber'], gameUID: map['gameUID'],
    idType: map['idType'], dob: map['dob'],
  );
}

// ─── Team Model ───────────────────────────────────────────────────────────────
class TeamModel {
  final String id;
  final String name;
  final String? logoUrl;
  final GameTitle game;
  final List<PlayerModel> players;
  final TeamStatus status;
  final String? country;
  final String? captainId;
  final String? contactInfo;
  final DateTime? createdAt;
  // Extended fields
  final int wins;
  final int losses;
  final String? description;
  final String? contactEmail;
  final String? socialLink;

  const TeamModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.game,
    this.players = const [],
    this.status = TeamStatus.pending,
    this.country,
    this.captainId,
    this.contactInfo,
    this.createdAt,
    this.wins = 0,
    this.losses = 0,
    this.description,
    this.contactEmail,
    this.socialLink,
  });

  TeamModel copyWith({
    String? id, String? name, String? logoUrl, GameTitle? game,
    List<PlayerModel>? players, TeamStatus? status, String? country,
    String? captainId, String? contactInfo, DateTime? createdAt,
    int? wins, int? losses, String? description, String? contactEmail, String? socialLink,
  }) => TeamModel(
    id: id ?? this.id, name: name ?? this.name, logoUrl: logoUrl ?? this.logoUrl,
    game: game ?? this.game, players: players ?? this.players,
    status: status ?? this.status, country: country ?? this.country,
    captainId: captainId ?? this.captainId, contactInfo: contactInfo ?? this.contactInfo,
    createdAt: createdAt ?? this.createdAt,
    wins: wins ?? this.wins, losses: losses ?? this.losses,
    description: description ?? this.description,
    contactEmail: contactEmail ?? this.contactEmail,
    socialLink: socialLink ?? this.socialLink,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'logoUrl': logoUrl, 'game': game.name,
    'players': players.map((p) => p.toMap()).toList(), 'status': status.name,
    'country': country, 'captainId': captainId, 'contactInfo': contactInfo,
    'createdAt': createdAt?.toIso8601String(),
    'wins': wins, 'losses': losses, 'description': description,
    'contactEmail': contactEmail, 'socialLink': socialLink,
  };

  factory TeamModel.fromMap(Map<String, dynamic> map) => TeamModel(
    id: map['id'] ?? '', name: map['name'] ?? '', logoUrl: map['logoUrl'],
    game: GameTitle.values.firstWhere((g) => g.name == map['game'], orElse: () => GameTitle.other),
    players: (map['players'] as List<dynamic>? ?? []).map((p) => PlayerModel.fromMap(p as Map<String, dynamic>)).toList(),
    status: TeamStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => TeamStatus.pending),
    country: map['country'], captainId: map['captainId'],
    contactInfo: map['contactInfo'],
    createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    wins: map['wins'] ?? 0, losses: map['losses'] ?? 0,
    description: map['description'], contactEmail: map['contactEmail'],
    socialLink: map['socialLink'],
  );
}

// ─── Match Model ──────────────────────────────────────────────────────────────
// Note: status is a plain String ('live', 'completed', 'upcoming') to match
// admin_dashboard.dart usage e.g. m.status == 'live'
class MatchModel {
  final String id;
  final String tournamentId;
  final String team1Id;
  final String team2Id;
  final int score1;
  final int score2;
  final String status;   // 'upcoming' | 'live' | 'completed'
  final String round;
  final String? winnerId;
  final String? scheduledAt;

  const MatchModel({
    required this.id,
    required this.tournamentId,
    required this.team1Id,
    required this.team2Id,
    this.score1 = 0,
    this.score2 = 0,
    this.status = 'upcoming',
    this.round = 'Round 1',
    this.winnerId,
    this.scheduledAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'tournamentId': tournamentId, 'team1Id': team1Id, 'team2Id': team2Id,
    'score1': score1, 'score2': score2, 'status': status, 'round': round,
    'winnerId': winnerId, 'scheduledAt': scheduledAt,
  };

  factory MatchModel.fromMap(Map<String, dynamic> map) => MatchModel(
    id: map['id'] ?? '', tournamentId: map['tournamentId'] ?? '',
    team1Id: map['team1Id'] ?? '', team2Id: map['team2Id'] ?? '',
    score1: map['score1'] ?? 0, score2: map['score2'] ?? 0,
    status: map['status'] ?? 'upcoming', round: map['round'] ?? 'Round 1',
    winnerId: map['winnerId'], scheduledAt: map['scheduledAt'],
  );
}

// ─── User Role ────────────────────────────────────────────────────────────────
enum UserRole {
  user,
  admin,
  organizer;

  String get label {
    switch (this) {
      case UserRole.user:      return 'Player';
      case UserRole.admin:     return 'Admin';
      case UserRole.organizer: return 'Organizer';
    }
  }
}

// ─── User Model ───────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? country;
  final UserRole role;
  final String? bio;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.country,
    this.role = UserRole.user,
    this.bio,
    this.avatarUrl,
  });
}

// ─── Standing Model ───────────────────────────────────────────────────────────
class StandingModel {
  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int losses;
  final int points;

  const StandingModel({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.wins,
    required this.losses,
    required this.points,
  });
}

// ─── Tournament Model ─────────────────────────────────────────────────────────
class TournamentModel {
  final String id;
  final String title;           // used as t.title in dashboard
  final GameTitle game;
  final TournamentStatus status;
  final TournamentFormat format;
  final String? description;
  final int? prizePool;
  final int maxTeams;
  final int registeredTeams;
  final List<MatchModel> matches;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? organizerId;
  final String? bannerUrl;
  final bool isVerified;
  // Extended fields
  final bool isFeatured;
  final List<TeamModel> teams;
  final List<StandingModel> standings;
  final String? organizer;
  final String? location;
  final DateTime? registrationDeadline;

  const TournamentModel({
    required this.id,
    required this.title,
    required this.game,
    required this.status,
    this.format = TournamentFormat.singleElim,
    this.description,
    this.prizePool,
    this.maxTeams = 16,
    this.registeredTeams = 0,
    this.matches = const [],
    this.startDate,
    this.endDate,
    this.organizerId,
    this.bannerUrl,
    this.isVerified = false,
    this.isFeatured = false,
    this.teams = const [],
    this.standings = const [],
    this.organizer,
    this.location,
    this.registrationDeadline,
  });

  bool get isFull => registeredTeams >= maxTeams;
  int get spotsLeft => maxTeams - registeredTeams;

  // Computed display getters
  String get prizePoolDisplay => prizePool != null ? '\$$prizePool' : 'TBA';
  String get startDateDisplay => startDate != null
      ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
      : 'TBA';
  String get endDateDisplay => endDate != null
      ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
      : 'TBA';
  String get registrationDeadlineDisplay => registrationDeadline != null
      ? '${registrationDeadline!.day}/${registrationDeadline!.month}/${registrationDeadline!.year}'
      : 'TBA';

  TournamentModel copyWith({
    String? id, String? title, GameTitle? game, TournamentStatus? status,
    TournamentFormat? format, String? description, int? prizePool,
    int? maxTeams, int? registeredTeams, List<MatchModel>? matches,
    DateTime? startDate, DateTime? endDate, String? organizerId,
    String? bannerUrl, bool? isVerified, bool? isFeatured,
    List<TeamModel>? teams, List<StandingModel>? standings,
    String? organizer, String? location, DateTime? registrationDeadline,
  }) => TournamentModel(
    id: id ?? this.id, title: title ?? this.title, game: game ?? this.game,
    status: status ?? this.status, format: format ?? this.format,
    description: description ?? this.description, prizePool: prizePool ?? this.prizePool,
    maxTeams: maxTeams ?? this.maxTeams, registeredTeams: registeredTeams ?? this.registeredTeams,
    matches: matches ?? this.matches, startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate, organizerId: organizerId ?? this.organizerId,
    bannerUrl: bannerUrl ?? this.bannerUrl, isVerified: isVerified ?? this.isVerified,
    isFeatured: isFeatured ?? this.isFeatured,
    teams: teams ?? this.teams, standings: standings ?? this.standings,
    organizer: organizer ?? this.organizer, location: location ?? this.location,
    registrationDeadline: registrationDeadline ?? this.registrationDeadline,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'game': game.name, 'status': status.name,
    'format': format.name, 'description': description, 'prizePool': prizePool,
    'maxTeams': maxTeams, 'registeredTeams': registeredTeams,
    'matches': matches.map((m) => m.toMap()).toList(),
    'startDate': startDate?.toIso8601String(), 'endDate': endDate?.toIso8601String(),
    'organizerId': organizerId, 'bannerUrl': bannerUrl, 'isVerified': isVerified,
    'isFeatured': isFeatured, 'organizer': organizer, 'location': location,
    'registrationDeadline': registrationDeadline?.toIso8601String(),
  };

  factory TournamentModel.fromMap(Map<String, dynamic> map) => TournamentModel(
    id: map['id'] ?? '', title: map['title'] ?? '',
    game: GameTitle.values.firstWhere((g) => g.name == map['game'], orElse: () => GameTitle.other),
    status: TournamentStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => TournamentStatus.upcoming),
    format: TournamentFormat.values.firstWhere((f) => f.name == map['format'], orElse: () => TournamentFormat.singleElim),
    description: map['description'], prizePool: map['prizePool'],
    maxTeams: map['maxTeams'] ?? 16, registeredTeams: map['registeredTeams'] ?? 0,
    matches: (map['matches'] as List<dynamic>? ?? []).map((m) => MatchModel.fromMap(m as Map<String, dynamic>)).toList(),
    startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
    endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
    organizerId: map['organizerId'], bannerUrl: map['bannerUrl'],
    isVerified: map['isVerified'] ?? false,
    isFeatured: map['isFeatured'] ?? false,
    organizer: map['organizer'], location: map['location'],
    registrationDeadline: map['registrationDeadline'] != null ? DateTime.tryParse(map['registrationDeadline']) : null,
  );
}