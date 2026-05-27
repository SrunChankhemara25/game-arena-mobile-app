import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. ADDED THIS IMPORT
import '../models/models.dart';
import 'backend_service.dart';

class AuthService {
  // ─── FIREBASE CLOUD FIRESTORE INSTANCE ───
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CONFIGURATION OBJECT FOR EMAILJS INTEGRATION ---
  static const String _serviceId = 'service_4lmycuh';
  static const String _templateId = 'template_9ouinbp';
  static const String _userId = 'AtIS3KzXnyr3jlPt2';

  /// 1. CHECK IF USER EXISTS
  Future<bool> checkUserExists(String email) async {
    final doc =
        await _db.collection('users').doc(email.toLowerCase().trim()).get();
    return doc.exists;
  }

  /// 2. GENERATES CODE, SAVES TO FIRESTORE, AND SENDS VIA EMAILJS
  Future<void> sendVerificationCode(String email) async {
    final String cleanEmail = email.toLowerCase().trim();

    // Generate a random 4-digit token between 1000 and 9999
    final String code = (1000 + Random().nextInt(9000)).toString();

    try {
      // Save the verification code into the Firestore Database temporarily
      await _db.collection('verification_codes').doc(cleanEmail).set({
        'code': code,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send the email via EmailJS API
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': {
            'email': cleanEmail,
            'code': code,
          },
        }),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw Exception(
              'Email delivery configuration error. Please verify your EmailJS setup settings.');
        }
        throw Exception(
            'Server rejected email payload: ${response.statusCode}');
      }

      // Debug console logs
      print('=============================================');
      print('VERIFICATION CODE SENT TO: $cleanEmail');
      print('LIVE FIRESTORE SECURITY CODE IS: $code');
      print('=============================================');
    } catch (e) {
      throw Exception('Verification service unavailable: $e');
    }
  }

  /// 3. VERIFIES THE ENTERED CODE AGAINST FIRESTORE DATABASE
  Future<bool> checkCode(String email, String inputCode) async {
    final String cleanEmail = email.toLowerCase().trim();

    final doc =
        await _db.collection('verification_codes').doc(cleanEmail).get();

    if (doc.exists && doc.data()?['code'] == inputCode.trim()) {
      await _db.collection('verification_codes').doc(cleanEmail).delete();
      return true;
    }

    return false;
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  String _preparePassword(String password) {
    return password.isEmpty ? '' : _hashPassword(password);
  }

  /// 4. REGISTER NEW USER: NAMED PARAMETERS TURNED ON TO MATCH VERIFY CODE SCREEN
  Future<void> registerUser({
    required String email,
    required String name,
    required String country,
    required String password,
    UserRole role = UserRole.user,
  }) async {
    final String cleanEmail = email.toLowerCase().trim();

    await _db.collection('users').doc(cleanEmail).set({
      'id': cleanEmail,
      'email': cleanEmail,
      'name': name,
      'country': country,
      'role': role.name,
      'status': 'active',
      'bio': '',
      'avatarUrl': null,
      'teamId': null,
      'notificationsEnabled': true,
      'emailUpdatesEnabled': true,
      'password': _preparePassword(password),
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await BackendService.instance.createNotification(
      AppNotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        userEmail: cleanEmail,
        title: 'Welcome to GameArena',
        body:
            'Your account is ready. Build your squad and join your first tournament.',
        type: 'welcome',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// 5. LOGIN EXISTING USER: CHECKS FIRESTORE IF ACCOUNT IS VALID
  Future<void> loginUser(String email, String password,
      {bool isGoogle = false}) async {
    final String cleanEmail = email.toLowerCase().trim();

    final doc = await _db.collection('users').doc(cleanEmail).get();

    if (!doc.exists) {
      throw Exception('Account does not exist in our system.');
    }

    if (!isGoogle) {
      final String storedPassword = doc.data()?['password'] as String? ?? '';
      final String hashedInput = _hashPassword(password);

      if (storedPassword != hashedInput && storedPassword != password) {
        throw Exception('Invalid password.');
      }
    }
  }

  /// 6. FORGOT PASSWORD: UPDATES PASSWORD IN FIRESTORE
  Future<void> resetPassword(String email, String newPassword) async {
    final String cleanEmail = email.toLowerCase().trim();

    await _db.collection('users').doc(cleanEmail).update({
      'password': _preparePassword(newPassword),
    });
  }

  // ─── 2. ADDED ONLY THIS PERSISTENCE LOGIC AT THE BOTTOM ───
  Future<void> saveUserSession(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_user_email', email.toLowerCase().trim());
  }

  Future<String?> getLoggedInUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_in_user_email');
  }

  Future<void> clearUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_email');
  }

  Future<UserModel?> getUserProfile(String email) {
    return BackendService.instance.getUserProfile(email);
  }

  Future<String> getUserRole(String email) async {
    final user = await BackendService.instance.getUserProfile(email);
    return user?.role.name ?? UserRole.user.name;
  }

  Future<void> updateUserProfile({
    required String email,
    required String name,
    required String country,
    String? bio,
    String? avatarUrl,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final existing = await BackendService.instance.getUserProfile(cleanEmail);
    final user = (existing ??
            UserModel(
              id: cleanEmail,
              name: name,
              email: cleanEmail,
              country: country,
            ))
        .copyWith(
      name: name,
      country: country,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    await BackendService.instance.saveUserProfile(user);
  }

  Future<void> updateUserPreferences({
    required String email,
    required bool notificationsEnabled,
    required bool emailUpdatesEnabled,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final existing = await BackendService.instance.getUserProfile(cleanEmail);
    if (existing == null) return;
    await BackendService.instance.saveUserProfile(
      existing.copyWith(
        notificationsEnabled: notificationsEnabled,
        emailUpdatesEnabled: emailUpdatesEnabled,
      ),
    );
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    await loginUser(cleanEmail, currentPassword);
    await resetPassword(cleanEmail, newPassword);
  }
}
