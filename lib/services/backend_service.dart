import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

class BackendService {
  BackendService._();

  static final BackendService instance = BackendService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _teams =>
      _db.collection('teams');
  CollectionReference<Map<String, dynamic>> get _tournaments =>
      _db.collection('tournaments');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _broadcasts =>
      _db.collection('broadcasts');

  bool _bootstrapped = false;

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  // ─── Tournaments ──────────────────────────────────────────────────────────

  Stream<List<TournamentModel>> watchTournaments() {
    return _tournaments.snapshots().map((snapshot) {
      final tournaments = snapshot.docs
          .map((doc) => TournamentModel.fromMap(doc.data()))
          .toList();
      tournaments.sort((a, b) => a.title.compareTo(b.title));
      return tournaments;
    });
  }

  Stream<TournamentModel?> watchTournament(String tournamentId) {
    return _tournaments.doc(tournamentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return TournamentModel.fromMap(doc.data()!);
    });
  }

  Future<List<TournamentModel>> getTournaments() async {
    final snapshot = await _tournaments.get();
    return snapshot.docs
        .map((doc) => TournamentModel.fromMap(doc.data()))
        .toList();
  }

  Future<TournamentModel?> getTournament(String tournamentId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TournamentModel.fromMap(doc.data()!);
  }

  Future<void> saveTournament(TournamentModel tournament) async {
    final normalized = tournament.copyWith(
      registeredTeams: tournament.teams.length,
    );
    final batch = _db.batch();
    batch.set(_tournaments.doc(normalized.id), normalized.toMap());
    for (final team in normalized.teams) {
      batch.set(_teams.doc(team.id), team.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> deleteTournament(String tournamentId) async {
    final tournament = await getTournament(tournamentId);
    final batch = _db.batch();
    batch.delete(_tournaments.doc(tournamentId));

    if (tournament != null) {
      for (final team in tournament.teams) {
        final savedTeam = await getTeam(team.id);
        if (savedTeam == null) continue;
        batch.set(
          _teams.doc(team.id),
          savedTeam
              .copyWith(
                registeredTournamentIds: savedTeam.registeredTournamentIds
                    .where((id) => id != tournamentId)
                    .toList(),
              )
              .toMap(),
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();
  }

  Future<void> setTournamentArchived(
      String tournamentId, bool isArchived) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null) return;
    await saveTournament(
      tournament.copyWith(
        isArchived: isArchived,
        status: isArchived ? TournamentStatus.ended : tournament.status,
      ),
    );
  }

  // ─── Teams ────────────────────────────────────────────────────────────────

  Stream<TeamModel?> watchTeamByOwner(String ownerEmail) {
    final normalizedEmail = _normalizeEmail(ownerEmail);
    return _teams
        .where('ownerEmail', isEqualTo: normalizedEmail)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TeamModel.fromMap(snapshot.docs.first.data());
    });
  }

  Future<TeamModel?> getTeamByOwner(String ownerEmail) async {
    final normalizedEmail = _normalizeEmail(ownerEmail);
    final snapshot = await _teams
        .where('ownerEmail', isEqualTo: normalizedEmail)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return TeamModel.fromMap(snapshot.docs.first.data());
  }

  Stream<List<TeamModel>> watchTeams() {
    return _teams.snapshots().map((snapshot) {
      final teams =
          snapshot.docs.map((doc) => TeamModel.fromMap(doc.data())).toList();
      teams.sort((a, b) => a.name.compareTo(b.name));
      return teams;
    });
  }

  Future<TeamModel?> getTeam(String teamId) async {
    final doc = await _teams.doc(teamId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TeamModel.fromMap(doc.data()!);
  }

  Future<void> saveTeam(TeamModel team) async {
    final normalized = team.copyWith(
      ownerEmail: team.ownerEmail?.trim().toLowerCase(),
    );
    final tournaments = await getTournaments();
    final batch = _db.batch();

    batch.set(_teams.doc(normalized.id), normalized.toMap());

    for (final tournament in tournaments) {
      var changed = false;
      final oldRefs = <String>{normalized.id.trim().toLowerCase()};
      final updatedTeams = tournament.teams.map((registeredTeam) {
        if (registeredTeam.id != normalized.id) return registeredTeam;
        changed = true;
        oldRefs.add(registeredTeam.name.trim().toLowerCase());
        oldRefs.add(normalized.name.trim().toLowerCase());
        return normalized.copyWith(
          status: registeredTeam.status,
          registeredTournamentIds: normalized.registeredTournamentIds.isNotEmpty
              ? normalized.registeredTournamentIds
              : registeredTeam.registeredTournamentIds,
        );
      }).toList();

      if (changed) {
        bool isTeamRef(String? value) =>
            value != null && oldRefs.contains(value.trim().toLowerCase());

        MatchModel syncMatchTeam(MatchModel match) {
          return MatchModel(
            id: match.id,
            tournamentId: match.tournamentId,
            team1Id: isTeamRef(match.team1Id) ? normalized.id : match.team1Id,
            team2Id: isTeamRef(match.team2Id) ? normalized.id : match.team2Id,
            score1: match.score1,
            score2: match.score2,
            status: match.status,
            round: match.round,
            winnerId:
                isTeamRef(match.winnerId) ? normalized.id : match.winnerId,
            scheduledAt: match.scheduledAt,
            venue: match.venue,
          );
        }

        final updatedStandings = tournament.standings.map((standing) {
          final standingRefs = [
            standing.teamId,
            standing.teamName,
          ].map((value) => value.trim().toLowerCase()).toSet();
          if (!standingRefs.any(oldRefs.contains)) return standing;
          return StandingModel(
            teamId: normalized.id,
            teamName: normalized.name,
            played: standing.played,
            wins: standing.wins,
            losses: standing.losses,
            points: standing.points,
          );
        }).toList();

        batch.set(
          _tournaments.doc(tournament.id),
          tournament
              .copyWith(
                teams: updatedTeams,
                registeredTeams: updatedTeams.length,
                standings: updatedStandings,
                matches: tournament.matches.map(syncMatchTeam).toList(),
                scheduleMatches:
                    tournament.scheduleMatches.map(syncMatchTeam).toList(),
                bracketMatches:
                    tournament.bracketMatches.map(syncMatchTeam).toList(),
              )
              .toMap(),
        );
      }
    }

    await batch.commit();
  }

  Future<void> deleteTeam(String teamId) async {
    final team = await getTeam(teamId);
    final batch = _db.batch();
    batch.delete(_teams.doc(teamId));

    if (team == null) {
      await batch.commit();
      return;
    }
    final tournaments = await getTournaments();
    for (final tournament in tournaments.where((entry) =>
        entry.teams.any((registeredTeam) => registeredTeam.id == teamId))) {
      final names = {
        teamId.trim().toLowerCase(),
        team.name.trim().toLowerCase(),
      }..remove('');
      bool referencesDeletedTeam(MatchModel match) {
        return [
          match.team1Id,
          match.team2Id,
          match.winnerId,
        ].whereType<String>().any((value) => names.contains(
              value.trim().toLowerCase(),
            ));
      }

      final updatedTeams = tournament.teams
          .where((registeredTeam) => registeredTeam.id != teamId)
          .toList();
      final updatedStandings = tournament.standings.where((standing) {
        return !names.contains(standing.teamId.trim().toLowerCase()) &&
            !names.contains(standing.teamName.trim().toLowerCase());
      }).toList();
      final updatedScheduleMatches = tournament.scheduleMatches
          .where((match) => !referencesDeletedTeam(match))
          .toList();
      final updatedBracketMatches = tournament.bracketMatches
          .where((match) => !referencesDeletedTeam(match))
          .toList();
      final updatedLegacyMatches = tournament.matches
          .where((match) => !referencesDeletedTeam(match))
          .toList();

      batch.set(
        _tournaments.doc(tournament.id),
        tournament
            .copyWith(
              teams: updatedTeams,
              registeredTeams: updatedTeams.length,
              standings: updatedStandings,
              scheduleMatches: updatedScheduleMatches,
              bracketMatches: updatedBracketMatches,
              matches: updatedLegacyMatches,
            )
            .toMap(),
      );
    }

    if (team.ownerEmail?.trim().isNotEmpty == true) {
      batch.set(
        _users.doc(_normalizeEmail(team.ownerEmail!)),
        {'teamId': null},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> registerTeamForTournament({
    required String tournamentId,
    required TeamModel team,
  }) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null) {
      throw Exception('Tournament not found.');
    }
    if (tournament.isArchived || tournament.status == TournamentStatus.ended) {
      throw Exception('Tournament is not accepting registrations.');
    }
    if (tournament.registeredTeams >= tournament.maxTeams ||
        tournament.teams.length >= tournament.maxTeams) {
      throw Exception('Tournament is already full.');
    }

    final normalizedOwner = team.ownerEmail?.trim().toLowerCase();
    final alreadyRegistered = tournament.teams.any((entry) {
      final sameTeam = entry.id == team.id;
      final sameOwner = normalizedOwner != null &&
          normalizedOwner.isNotEmpty &&
          entry.ownerEmail?.trim().toLowerCase() == normalizedOwner;
      return sameTeam || sameOwner;
    });
    if (alreadyRegistered) {
      throw Exception(
          'This account is already registered for this tournament.');
    }

    final normalizedTeam = team.copyWith(
      status: TeamStatus.pending,
      ownerEmail: normalizedOwner,
      registeredTournamentIds: {
        ...team.registeredTournamentIds,
        tournamentId,
      }.toList(),
    );

    final updatedTeams = List<TeamModel>.from(tournament.teams)
      ..add(normalizedTeam);

    await saveTeam(normalizedTeam);
    await saveTournament(
      tournament.copyWith(
        teams: updatedTeams,
        registeredTeams: updatedTeams.length,
      ),
    );

    if (normalizedOwner?.isNotEmpty == true) {
      final owner = await getUserProfile(normalizedOwner!);
      if (owner != null) {
        await saveUserProfile(owner.copyWith(teamId: normalizedTeam.id));
      }
      await createNotification(
        AppNotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userEmail: normalizedOwner,
          title: 'Roster Submitted',
          body:
              '${normalizedTeam.name} is now pending review for ${tournament.title}.',
          type: 'registration',
          createdAt: DateTime.now(),
          tournamentId: tournament.id,
          teamId: normalizedTeam.id,
        ),
      );
    }
  }

  Future<void> updateTeamApproval({
    required String tournamentId,
    required String teamId,
    required TeamStatus status,
  }) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null) return;

    final updatedTeams = tournament.teams
        .map((team) => team.id == teamId ? team.copyWith(status: status) : team)
        .toList();

    await saveTournament(
      tournament.copyWith(
        teams: updatedTeams,
        registeredTeams: updatedTeams.length,
      ),
    );

    final team = updatedTeams.firstWhere(
      (entry) => entry.id == teamId,
      orElse: () => TeamModel(id: teamId, name: 'Team', game: tournament.game),
    );

    final savedTeam = await getTeam(teamId);
    if (savedTeam != null) {
      await saveTeam(savedTeam.copyWith(status: status));
    }

    if (team.ownerEmail?.isNotEmpty == true) {
      final decision = switch (status) {
        TeamStatus.approved => 'approved',
        TeamStatus.rejected => 'rejected',
        TeamStatus.pending => 'moved back to pending review',
      };
      await createNotification(
        AppNotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userEmail: team.ownerEmail!,
          title: status == TeamStatus.approved
              ? 'Team Approved'
              : status == TeamStatus.rejected
                  ? 'Team Rejected'
                  : 'Review Updated',
          body: '${team.name} was $decision for ${tournament.title}.',
          type: 'approval',
          createdAt: DateTime.now(),
          tournamentId: tournament.id,
          teamId: team.id,
        ),
      );
    }
  }

  // ─── Users ────────────────────────────────────────────────────────────────

  Future<UserModel?> getUserProfile(String email) async {
    final doc = await _users.doc(_normalizeEmail(email)).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> watchUserProfile(String email) {
    return _users.doc(_normalizeEmail(email)).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  Stream<List<UserModel>> watchUsers() {
    return _users.snapshots().map((snapshot) {
      final users =
          snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      users.sort((a, b) => a.name.compareTo(b.name));
      return users;
    });
  }

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _users.doc(_normalizeEmail(user.email)).set(
          user.copyWith(id: _normalizeEmail(user.email)).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateUserStatus(String email, String status) async {
    await _users.doc(_normalizeEmail(email)).set(
      {'status': status},
      SetOptions(merge: true),
    );
  }

  Future<void> deleteUser(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    final team = await getTeamByOwner(normalizedEmail);
    if (team != null) {
      await deleteTeam(team.id);
    }

    final notifications = await _notifications
        .where('userEmail', isEqualTo: normalizedEmail)
        .get();
    final batch = _db.batch();
    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_users.doc(normalizedEmail));
    await batch.commit();
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Stream<List<AppNotificationModel>> watchNotifications(String email) {
    return _notifications
        .where('userEmail', isEqualTo: _normalizeEmail(email))
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AppNotificationModel.fromMap(doc.data()))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Stream<int> watchUnreadNotificationCount(String email) {
    return watchNotifications(email).map((items) =>
        items.where((item) => !item.read && !item.archived).toList().length);
  }

  Future<void> createNotification(AppNotificationModel notification) async {
    await _notifications.doc(notification.id).set(notification.toMap());
  }

  Future<void> markNotificationRead(String notificationId, bool read) async {
    await _notifications.doc(notificationId).set(
      {'read': read},
      SetOptions(merge: true),
    );
  }

  Future<void> archiveNotification(String notificationId, bool archived) async {
    await _notifications.doc(notificationId).set(
      {'archived': archived},
      SetOptions(merge: true),
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }

  // ─── Broadcasts ───────────────────────────────────────────────────────────

  Future<void> sendBroadcast({
    required String title,
    required String message,
    String? targetEmail,
  }) async {
    final recipients = targetEmail == null || targetEmail.trim().isEmpty
        ? await getUsers()
        : [
            await getUserProfile(targetEmail),
          ].whereType<UserModel>().toList();

    if (recipients.isEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();

    for (final user in recipients) {
      final notification = AppNotificationModel(
        id: 'notif_${now.microsecondsSinceEpoch}_${user.id}',
        userEmail: user.email,
        title: title.trim().isEmpty ? 'GameArena Update' : title.trim(),
        body: message.trim(),
        type: 'broadcast',
        createdAt: now,
      );
      batch.set(_notifications.doc(notification.id), notification.toMap());
    }

    await batch.commit();
  }

  /// Save a broadcast history record so admins can see what was sent.
  Future<void> saveBroadcastRecord(BroadcastRecord record) async {
    await _broadcasts.doc(record.id).set(record.toMap());
  }

  /// Delete a broadcast history record.
  Future<void> deleteBroadcastRecord(String id) async {
    await _broadcasts.doc(id).delete();
  }

  Future<void> archiveBroadcastRecord(String id, bool archived) async {
    await _broadcasts.doc(id).set(
      {'archived': archived},
      SetOptions(merge: true),
    );
  }

  /// Fetch all past broadcast records sorted newest-first.
  Future<List<BroadcastRecord>> getBroadcastHistory() async {
    final snapshot =
        await _broadcasts.orderBy('sentAt', descending: true).get();
    return snapshot.docs
        .map((doc) => BroadcastRecord.fromMap(doc.data()))
        .toList();
  }

  /// Real-time stream of broadcast history for the admin panel.
  Stream<List<BroadcastRecord>> watchBroadcastHistory() {
    return _broadcasts.orderBy('sentAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => BroadcastRecord.fromMap(doc.data()))
            .toList());
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  String formatRelativeTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w ago';
    return '${value.day}/${value.month}/${value.year}';
  }
}

// ─── Broadcast Record Model ───────────────────────────────────────────────────

class BroadcastRecord {
  final String id;
  final String title;
  final String message;
  final String recipient;
  final DateTime sentAt;
  final bool archived;

  BroadcastRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.recipient,
    required this.sentAt,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'recipient': recipient,
        'sentAt': sentAt.toIso8601String(),
        'archived': archived,
      };

  factory BroadcastRecord.fromMap(Map<String, dynamic> map) => BroadcastRecord(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        recipient: map['recipient'] ?? '',
        sentAt: DateTime.tryParse(map['sentAt'] ?? '') ?? DateTime.now(),
        archived: map['archived'] ?? false,
      );
}
