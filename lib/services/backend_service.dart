import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../data/mock_data.dart';
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

  bool _bootstrapped = false;

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    await _seedUsers();
    await _seedTeams();
    await _seedTournaments();
    _bootstrapped = true;
  }

  Future<void> _seedUsers() async {
    const users = <Map<String, dynamic>>[
      {
        'email': 'admin@gamearena.gg',
        'name': 'Nova Admin',
        'country': 'Cambodia',
        'role': 'admin',
        'status': 'active',
        'password': 'admin123',
      },
      {
        'email': 'player@gamearena.gg',
        'name': 'Vortex Striker',
        'country': 'Cambodia',
        'role': 'user',
        'status': 'active',
        'password': 'player123',
      },
      {
        'email': 'manager@gamearena.gg',
        'name': 'Arena Manager',
        'country': 'Philippines',
        'role': 'organizer',
        'status': 'active',
        'password': 'manager123',
      },
    ];

    final batch = _db.batch();
    var hasWrites = false;

    for (final seed in users) {
      final email = _normalizeEmail(seed['email'] as String);
      final ref = _users.doc(email);
      final snap = await ref.get();
      if (snap.exists) continue;
      hasWrites = true;
      batch.set(ref, {
        'id': email,
        'email': email,
        'name': seed['name'],
        'country': seed['country'],
        'role': seed['role'],
        'status': seed['status'],
        'bio': '',
        'avatarUrl': null,
        'teamId': null,
        'notificationsEnabled': true,
        'emailUpdatesEnabled': true,
        'createdAt': DateTime.now().toIso8601String(),
        'password': _hashPassword(seed['password'] as String),
      });
    }

    if (hasWrites) {
      await batch.commit();
    }
  }

  Future<void> _seedTeams() async {
    final snapshot = await _teams.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final team in MockData.teams) {
      batch.set(_teams.doc(team.id), team.toMap());
    }
    await batch.commit();
  }

  Future<void> _seedTournaments() async {
    final snapshot = await _tournaments.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final tournament in MockData.tournaments.map(_decorateTournament)) {
      batch.set(_tournaments.doc(tournament.id), tournament.toMap());
    }
    await batch.commit();
  }

  TournamentModel _decorateTournament(TournamentModel tournament) {
    final teams = tournament.teams
        .map(
          (team) => team.copyWith(
            contactPhone: team.contactPhone ?? '',
            coachName: team.coachName ?? _firstByType(team, PlayerType.coach),
            assistantCoachName: team.assistantCoachName ??
                _firstByType(team, PlayerType.assistantCoach),
          ),
        )
        .toList();

    return tournament.copyWith(
      logoUrl: _defaultLogoForGame(tournament.game),
      type: _defaultTypeForGame(tournament.game),
      requirements: _defaultRequirementsForGame(tournament.game),
      teams: teams,
      registeredTeams: teams.length,
      isArchived: tournament.status == TournamentStatus.ended,
    );
  }

  String _firstByType(TeamModel team, PlayerType type) {
    final player =
        team.players.where((entry) => entry.type == type).firstOrNull;
    return player?.fullName ?? player?.ign ?? '';
  }

  String _defaultTypeForGame(GameTitle game) {
    switch (game) {
      case GameTitle.pubg:
      case GameTitle.freeFire:
        return 'Squad';
      default:
        return '5v5';
    }
  }

  String _defaultRequirementsForGame(GameTitle game) {
    return 'Verified ${game.label} roster, valid player IDs, and an active team manager contact are required.';
  }

  String? _defaultLogoForGame(GameTitle game) {
    switch (game) {
      case GameTitle.mlbb:
        return 'https://upload.wikimedia.org/wikipedia/en/thumb/9/90/Mobile_Legends_Bang_Bang_logo.png/320px-Mobile_Legends_Bang_Bang_logo.png';
      case GameTitle.pubg:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/PUBG_Mobile_logo.svg/320px-PUBG_Mobile_logo.svg.png';
      case GameTitle.freeFire:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Garena_Free_Fire_logo.svg/320px-Garena_Free_Fire_logo.svg.png';
      case GameTitle.valorant:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Valorant_logo_-_pink_color_version.svg/320px-Valorant_logo_-_pink_color_version.svg.png';
      case GameTitle.cod:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Call_of_Duty_Mobile_logo.svg/320px-Call_of_Duty_Mobile_logo.svg.png';
      case GameTitle.eFootball:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/EFootball_logo.svg/320px-EFootball_logo.svg.png';
      case GameTitle.other:
        return null;
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

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
    await _tournaments.doc(normalized.id).set(normalized.toMap());
  }

  Future<void> deleteTournament(String tournamentId) async {
    await _tournaments.doc(tournamentId).delete();
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
    await _teams.doc(team.id).set(team.toMap());
  }

  Future<void> deleteTeam(String teamId) async {
    final team = await getTeam(teamId);
    await _teams.doc(teamId).delete();

    if (team == null) return;
    final tournaments = await getTournaments();
    for (final tournament in tournaments.where((entry) =>
        entry.teams.any((registeredTeam) => registeredTeam.id == teamId))) {
      final updatedTeams = tournament.teams
          .where((registeredTeam) => registeredTeam.id != teamId)
          .toList();
      await saveTournament(
        tournament.copyWith(
          teams: updatedTeams,
          registeredTeams: updatedTeams.length,
        ),
      );
    }
  }

  Future<void> registerTeamForTournament({
    required String tournamentId,
    required TeamModel team,
  }) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null) return;

    final normalizedTeam = team.copyWith(
      status: TeamStatus.pending,
      registeredTournamentIds: {
        ...team.registeredTournamentIds,
        tournamentId,
      }.toList(),
    );

    final updatedTeams = tournament.teams
        .where((entry) => entry.id != normalizedTeam.id)
        .toList()
      ..add(normalizedTeam);

    await saveTeam(normalizedTeam);
    await saveTournament(
      tournament.copyWith(
        teams: updatedTeams,
        registeredTeams: updatedTeams.length,
      ),
    );

    if (normalizedTeam.ownerEmail?.isNotEmpty == true) {
      final owner = await getUserProfile(normalizedTeam.ownerEmail!);
      if (owner != null) {
        await saveUserProfile(owner.copyWith(teamId: normalizedTeam.id));
      }
      await createNotification(
        AppNotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userEmail: normalizedTeam.ownerEmail!,
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
      await createNotification(
        AppNotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userEmail: team.ownerEmail!,
          title: status == TeamStatus.approved
              ? 'Team Approved'
              : status == TeamStatus.rejected
                  ? 'Team Rejected'
                  : 'Review Updated',
          body:
              '${team.name} is now ${status.label.toLowerCase()} for ${tournament.title}.',
          type: 'approval',
          createdAt: DateTime.now(),
          tournamentId: tournament.id,
          teamId: team.id,
        ),
      );
    }
  }

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
