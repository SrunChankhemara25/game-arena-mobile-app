// lib/models/models.dart

// ─── Tournament Status ────────────────────────────────────────────────────────
enum TournamentStatus {
  ongoing,
  registration,
  upcoming,
  ended;

  String get label {
    switch (this) {
      case TournamentStatus.ongoing:
        return 'LIVE';
      case TournamentStatus.registration:
        return 'OPEN';
      case TournamentStatus.upcoming:
        return 'SOON';
      case TournamentStatus.ended:
        return 'ENDED';
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
      case TeamStatus.pending:
        return 'PENDING';
      case TeamStatus.approved:
        return 'APPROVED';
      case TeamStatus.rejected:
        return 'REJECTED';
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
      case TournamentFormat.singleElim:
        return 'Single Elim';
      case TournamentFormat.doubleElim:
        return 'Double Elim';
      case TournamentFormat.groupStage:
        return 'Group Stage';
      case TournamentFormat.groupAndElim:
        return 'Group + Playoffs';
      case TournamentFormat.roundRobin:
        return 'Round Robin';
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
      case GameTitle.mlbb:
        return 'MLBB';
      case GameTitle.pubg:
        return 'PUBG';
      case GameTitle.freeFire:
        return 'Free Fire';
      case GameTitle.valorant:
        return 'Valorant';
      case GameTitle.cod:
        return 'COD Mobile';
      case GameTitle.eFootball:
        return 'eFootball';
      case GameTitle.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case GameTitle.mlbb:
        return '⚔️';
      case GameTitle.pubg:
        return '🪖';
      case GameTitle.freeFire:
        return '🔥';
      case GameTitle.valorant:
        return '🎯';
      case GameTitle.cod:
        return '💣';
      case GameTitle.eFootball:
        return '⚽';
      case GameTitle.other:
        return '🎮';
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
      case PlayerType.main:
        return 'Main';
      case PlayerType.substitute:
        return 'Substitute';
      case PlayerType.coach:
        return 'Coach';
      case PlayerType.assistantCoach:
        return 'Asst. Coach';
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
        'id': id,
        'ign': ign,
        'realName': realName,
        'avatarUrl': avatarUrl,
        'type': type.name,
        'teamId': teamId,
        'game': game?.name,
        'contactInfo': contactInfo,
        'fullName': fullName,
        'role': role,
        'nationality': nationality,
        'jerseyNumber': jerseyNumber,
        'gameUID': gameUID,
        'idType': idType,
        'dob': dob,
      };

  factory PlayerModel.fromMap(Map<String, dynamic> map) => PlayerModel(
        id: map['id'] ?? '',
        ign: map['ign'] ?? '',
        realName: map['realName'],
        avatarUrl: map['avatarUrl'],
        type: PlayerType.values.firstWhere((t) => t.name == map['type'],
            orElse: () => PlayerType.main),
        teamId: map['teamId'],
        game: map['game'] != null
            ? GameTitle.values.firstWhere((g) => g.name == map['game'],
                orElse: () => GameTitle.other)
            : null,
        contactInfo: map['contactInfo'],
        fullName: map['fullName'],
        role: map['role'],
        nationality: map['nationality'],
        jerseyNumber: map['jerseyNumber'],
        gameUID: map['gameUID'],
        idType: map['idType'],
        dob: map['dob'],
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
  final String? teamTag;
  final String? ownerEmail;
  final String? founderName;
  final String? managerName;
  final String? coachName;
  final String? assistantCoachName;
  final String? contactPhone;
  final List<String> registeredTournamentIds;

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
    this.teamTag,
    this.ownerEmail,
    this.founderName,
    this.managerName,
    this.coachName,
    this.assistantCoachName,
    this.contactPhone,
    this.registeredTournamentIds = const [],
  });

  TeamModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    GameTitle? game,
    List<PlayerModel>? players,
    TeamStatus? status,
    String? country,
    String? captainId,
    String? contactInfo,
    DateTime? createdAt,
    int? wins,
    int? losses,
    String? description,
    String? contactEmail,
    String? socialLink,
    String? teamTag,
    String? ownerEmail,
    String? founderName,
    String? managerName,
    String? coachName,
    String? assistantCoachName,
    String? contactPhone,
    List<String>? registeredTournamentIds,
  }) =>
      TeamModel(
        id: id ?? this.id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        game: game ?? this.game,
        players: players ?? this.players,
        status: status ?? this.status,
        country: country ?? this.country,
        captainId: captainId ?? this.captainId,
        contactInfo: contactInfo ?? this.contactInfo,
        createdAt: createdAt ?? this.createdAt,
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        description: description ?? this.description,
        contactEmail: contactEmail ?? this.contactEmail,
        socialLink: socialLink ?? this.socialLink,
        teamTag: teamTag ?? this.teamTag,
        ownerEmail: ownerEmail ?? this.ownerEmail,
        founderName: founderName ?? this.founderName,
        managerName: managerName ?? this.managerName,
        coachName: coachName ?? this.coachName,
        assistantCoachName: assistantCoachName ?? this.assistantCoachName,
        contactPhone: contactPhone ?? this.contactPhone,
        registeredTournamentIds:
            registeredTournamentIds ?? this.registeredTournamentIds,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'game': game.name,
        'players': players.map((p) => p.toMap()).toList(),
        'status': status.name,
        'country': country,
        'captainId': captainId,
        'contactInfo': contactInfo,
        'createdAt': createdAt?.toIso8601String(),
        'wins': wins,
        'losses': losses,
        'description': description,
        'contactEmail': contactEmail,
        'socialLink': socialLink,
        'teamTag': teamTag,
        'ownerEmail': ownerEmail,
        'founderName': founderName,
        'managerName': managerName,
        'coachName': coachName,
        'assistantCoachName': assistantCoachName,
        'contactPhone': contactPhone,
        'registeredTournamentIds': registeredTournamentIds,
      };

  factory TeamModel.fromMap(Map<String, dynamic> map) => TeamModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        logoUrl: map['logoUrl'],
        game: GameTitle.values.firstWhere((g) => g.name == map['game'],
            orElse: () => GameTitle.other),
        players: (map['players'] as List<dynamic>? ?? [])
            .map((p) => PlayerModel.fromMap(p as Map<String, dynamic>))
            .toList(),
        status: TeamStatus.values.firstWhere((s) => s.name == map['status'],
            orElse: () => TeamStatus.pending),
        country: map['country'],
        captainId: map['captainId'],
        contactInfo: map['contactInfo'],
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'])
            : null,
        wins: map['wins'] ?? 0,
        losses: map['losses'] ?? 0,
        description: map['description'],
        contactEmail: map['contactEmail'],
        socialLink: map['socialLink'],
        teamTag: map['teamTag'],
        ownerEmail: map['ownerEmail'],
        founderName: map['founderName'],
        managerName: map['managerName'],
        coachName: map['coachName'],
        assistantCoachName: map['assistantCoachName'],
        contactPhone: map['contactPhone'],
        registeredTournamentIds:
            (map['registeredTournamentIds'] as List<dynamic>? ?? [])
                .map((id) => '$id')
                .toList(),
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
  final String status; // 'upcoming' | 'live' | 'completed'
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
        'id': id,
        'tournamentId': tournamentId,
        'team1Id': team1Id,
        'team2Id': team2Id,
        'score1': score1,
        'score2': score2,
        'status': status,
        'round': round,
        'winnerId': winnerId,
        'scheduledAt': scheduledAt,
      };

  factory MatchModel.fromMap(Map<String, dynamic> map) => MatchModel(
        id: map['id'] ?? '',
        tournamentId: map['tournamentId'] ?? '',
        team1Id: map['team1Id'] ?? '',
        team2Id: map['team2Id'] ?? '',
        score1: map['score1'] ?? 0,
        score2: map['score2'] ?? 0,
        status: map['status'] ?? 'upcoming',
        round: map['round'] ?? 'Round 1',
        winnerId: map['winnerId'],
        scheduledAt: map['scheduledAt'],
      );
}

// ─── User Role ────────────────────────────────────────────────────────────────
enum UserRole {
  user,
  admin,
  organizer;

  String get label {
    switch (this) {
      case UserRole.user:
        return 'Player';
      case UserRole.admin:
        return 'Admin';
      case UserRole.organizer:
        return 'Organizer';
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
  final String status;
  final bool notificationsEnabled;
  final bool emailUpdatesEnabled;
  final String? teamId;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.country,
    this.role = UserRole.user,
    this.bio,
    this.avatarUrl,
    this.status = 'active',
    this.notificationsEnabled = true,
    this.emailUpdatesEnabled = true,
    this.teamId,
    this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? country,
    UserRole? role,
    String? bio,
    String? avatarUrl,
    String? status,
    bool? notificationsEnabled,
    bool? emailUpdatesEnabled,
    String? teamId,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        country: country ?? this.country,
        role: role ?? this.role,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        status: status ?? this.status,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        emailUpdatesEnabled: emailUpdatesEnabled ?? this.emailUpdatesEnabled,
        teamId: teamId ?? this.teamId,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'country': country,
        'role': role.name,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'status': status,
        'notificationsEnabled': notificationsEnabled,
        'emailUpdatesEnabled': emailUpdatesEnabled,
        'teamId': teamId,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        country: map['country'],
        role: UserRole.values.firstWhere(
          (value) => value.name == map['role'],
          orElse: () => UserRole.user,
        ),
        bio: map['bio'],
        avatarUrl: map['avatarUrl'],
        status: map['status'] ?? 'active',
        notificationsEnabled: map['notificationsEnabled'] ?? true,
        emailUpdatesEnabled: map['emailUpdatesEnabled'] ?? true,
        teamId: map['teamId'],
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'])
            : null,
      );
}

class AppNotificationModel {
  final String id;
  final String userEmail;
  final String title;
  final String body;
  final String type;
  final bool read;
  final bool archived;
  final DateTime createdAt;
  final String? tournamentId;
  final String? teamId;

  const AppNotificationModel({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.archived = false,
    this.tournamentId,
    this.teamId,
  });

  AppNotificationModel copyWith({
    String? id,
    String? userEmail,
    String? title,
    String? body,
    String? type,
    bool? read,
    bool? archived,
    DateTime? createdAt,
    String? tournamentId,
    String? teamId,
  }) =>
      AppNotificationModel(
        id: id ?? this.id,
        userEmail: userEmail ?? this.userEmail,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        read: read ?? this.read,
        archived: archived ?? this.archived,
        createdAt: createdAt ?? this.createdAt,
        tournamentId: tournamentId ?? this.tournamentId,
        teamId: teamId ?? this.teamId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'title': title,
        'body': body,
        'type': type,
        'read': read,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
        'tournamentId': tournamentId,
        'teamId': teamId,
      };

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) =>
      AppNotificationModel(
        id: map['id'] ?? '',
        userEmail: map['userEmail'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        type: map['type'] ?? 'general',
        read: map['read'] ?? false,
        archived: map['archived'] ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        tournamentId: map['tournamentId'],
        teamId: map['teamId'],
      );
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

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'teamName': teamName,
        'played': played,
        'wins': wins,
        'losses': losses,
        'points': points,
      };

  factory StandingModel.fromMap(Map<String, dynamic> map) => StandingModel(
        teamId: map['teamId'] ?? '',
        teamName: map['teamName'] ?? '',
        played: map['played'] ?? 0,
        wins: map['wins'] ?? 0,
        losses: map['losses'] ?? 0,
        points: map['points'] ?? 0,
      );
}

// ─── Tournament Model ─────────────────────────────────────────────────────────
class TournamentModel {
  final String id;
  final String title; // used as t.title in dashboard
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
  final String? logoUrl;
  final bool isVerified;
  // Extended fields
  final bool isFeatured;
  final List<TeamModel> teams;
  final List<StandingModel> standings;
  final String? organizer;
  final String? location;
  final DateTime? registrationDeadline;
  final String type;
  final String? requirements;
  final bool isArchived;

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
    this.logoUrl,
    this.isVerified = false,
    this.isFeatured = false,
    this.teams = const [],
    this.standings = const [],
    this.organizer,
    this.location,
    this.registrationDeadline,
    this.type = 'Squad',
    this.requirements,
    this.isArchived = false,
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
    String? id,
    String? title,
    GameTitle? game,
    TournamentStatus? status,
    TournamentFormat? format,
    String? description,
    int? prizePool,
    int? maxTeams,
    int? registeredTeams,
    List<MatchModel>? matches,
    DateTime? startDate,
    DateTime? endDate,
    String? organizerId,
    String? bannerUrl,
    String? logoUrl,
    bool? isVerified,
    bool? isFeatured,
    List<TeamModel>? teams,
    List<StandingModel>? standings,
    String? organizer,
    String? location,
    DateTime? registrationDeadline,
    String? type,
    String? requirements,
    bool? isArchived,
  }) =>
      TournamentModel(
        id: id ?? this.id,
        title: title ?? this.title,
        game: game ?? this.game,
        status: status ?? this.status,
        format: format ?? this.format,
        description: description ?? this.description,
        prizePool: prizePool ?? this.prizePool,
        maxTeams: maxTeams ?? this.maxTeams,
        registeredTeams: registeredTeams ?? this.registeredTeams,
        matches: matches ?? this.matches,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        organizerId: organizerId ?? this.organizerId,
        bannerUrl: bannerUrl ?? this.bannerUrl,
        logoUrl: logoUrl ?? this.logoUrl,
        isVerified: isVerified ?? this.isVerified,
        isFeatured: isFeatured ?? this.isFeatured,
        teams: teams ?? this.teams,
        standings: standings ?? this.standings,
        organizer: organizer ?? this.organizer,
        location: location ?? this.location,
        registrationDeadline: registrationDeadline ?? this.registrationDeadline,
        type: type ?? this.type,
        requirements: requirements ?? this.requirements,
        isArchived: isArchived ?? this.isArchived,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'game': game.name,
        'status': status.name,
        'format': format.name,
        'description': description,
        'prizePool': prizePool,
        'maxTeams': maxTeams,
        'registeredTeams': registeredTeams,
        'matches': matches.map((m) => m.toMap()).toList(),
        'teams': teams.map((team) => team.toMap()).toList(),
        'standings': standings.map((standing) => standing.toMap()).toList(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'organizerId': organizerId,
        'bannerUrl': bannerUrl,
        'logoUrl': logoUrl,
        'isVerified': isVerified,
        'isFeatured': isFeatured,
        'organizer': organizer,
        'location': location,
        'registrationDeadline': registrationDeadline?.toIso8601String(),
        'type': type,
        'requirements': requirements,
        'isArchived': isArchived,
      };

  factory TournamentModel.fromMap(Map<String, dynamic> map) => TournamentModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        game: GameTitle.values.firstWhere((g) => g.name == map['game'],
            orElse: () => GameTitle.other),
        status: TournamentStatus.values.firstWhere(
            (s) => s.name == map['status'],
            orElse: () => TournamentStatus.upcoming),
        format: TournamentFormat.values.firstWhere(
            (f) => f.name == map['format'],
            orElse: () => TournamentFormat.singleElim),
        description: map['description'],
        prizePool: map['prizePool'],
        maxTeams: map['maxTeams'] ?? 16,
        registeredTeams: map['registeredTeams'] ?? 0,
        matches: (map['matches'] as List<dynamic>? ?? [])
            .map((m) => MatchModel.fromMap(m as Map<String, dynamic>))
            .toList(),
        teams: (map['teams'] as List<dynamic>? ?? [])
            .map((team) =>
                TeamModel.fromMap(Map<String, dynamic>.from(team as Map)))
            .toList(),
        standings: (map['standings'] as List<dynamic>? ?? [])
            .map((standing) => StandingModel.fromMap(
                Map<String, dynamic>.from(standing as Map)))
            .toList(),
        startDate: map['startDate'] != null
            ? DateTime.tryParse(map['startDate'])
            : null,
        endDate:
            map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
        organizerId: map['organizerId'],
        bannerUrl: map['bannerUrl'],
        logoUrl: map['logoUrl'],
        isVerified: map['isVerified'] ?? false,
        isFeatured: map['isFeatured'] ?? false,
        organizer: map['organizer'],
        location: map['location'],
        registrationDeadline: map['registrationDeadline'] != null
            ? DateTime.tryParse(map['registrationDeadline'])
            : null,
        type: map['type'] ?? 'Squad',
        requirements: map['requirements'],
        isArchived: map['isArchived'] ?? false,
      );
}
