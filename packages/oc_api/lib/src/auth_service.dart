import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Authentication service — Firebase Auth for phone OTP, Supabase for DB.
/// Uses platform-specific phone auth:
///   Web:    signInWithPhoneNumber() → ConfirmationResult.confirm()
///   Mobile: verifyPhoneNumber() → PhoneAuthProvider.credential()
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final fb.FirebaseAuth _fbAuth = fb.FirebaseAuth.instance;
  final SupabaseClient _db = OcSupabase.client;

  // Mobile: stores verification ID from codeSent callback
  String? _verificationId;
  // Web: stores the ConfirmationResult from signInWithPhoneNumber
  fb.ConfirmationResult? _webConfirmation;

  /// Send OTP to phone number.
  /// On web: uses signInWithPhoneNumber (handles reCAPTCHA automatically).
  /// On mobile: uses verifyPhoneNumber with codeSent callback.
  Future<void> signInWithOtp(String phone) async {
    if (kIsWeb) {
      // Web: signInWithPhoneNumber returns ConfirmationResult
      _webConfirmation = await _fbAuth.signInWithPhoneNumber(phone);
    } else {
      // Mobile: use verifyPhoneNumber
      final completer = Completer<void>();

      await _fbAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _fbAuth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(e.message ?? 'فشل في إرسال الرمز'));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return completer.future;
    }
  }

  /// Verify OTP code.
  /// On web: uses ConfirmationResult.confirm(code).
  /// On mobile: uses PhoneAuthProvider.credential + signInWithCredential.
  Future<fb.UserCredential> verifyOtp({
    required String phone,
    required String token,
  }) async {
    if (kIsWeb) {
      if (_webConfirmation == null) {
        throw Exception('يرجى إرسال الرمز أولاً');
      }
      return await _webConfirmation!.confirm(token);
    } else {
      if (_verificationId == null) {
        throw Exception('يرجى إرسال الرمز أولاً');
      }
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: token,
      );
      return await _fbAuth.signInWithCredential(credential);
    }
  }

  /// Sign out from both Firebase and Supabase.
  Future<void> signOut() async {
    await _fbAuth.signOut();
    await _db.auth.signOut();
  }

  /// Check if user is authenticated via Firebase.
  bool get isAuthenticated => _fbAuth.currentUser != null;

  /// Get current Firebase user.
  fb.User? get currentUser => _fbAuth.currentUser;

  /// Get current Firebase user ID.
  String? get currentUserId => _fbAuth.currentUser?.uid;

  /// Stream auth state changes from Firebase.
  Stream<fb.User?> get onAuthStateChange => _fbAuth.authStateChanges();

  /// Check if user has completed profile setup in Supabase.
  Future<bool> hasCompletedProfile() async {
    final user = _fbAuth.currentUser;
    if (user == null) return false;

    final data = await _db
        .from('users')
        .select('name')
        .eq('id', user.uid)
        .maybeSingle();

    return data != null && data['name'] != null && data['name'].toString().isNotEmpty;
  }

  /// Get user roles from Supabase.
  Future<List<String>> getUserRoles() async {
    final user = _fbAuth.currentUser;
    if (user == null) return [];

    final data = await _db
        .from('user_roles')
        .select('role')
        .eq('user_id', user.uid)
        .eq('is_active', true);

    return (data as List).map((r) => r['role'] as String).toList();
  }

  /// Update FCM token in Supabase.
  Future<void> updateFcmToken(String token) async {
    final user = _fbAuth.currentUser;
    if (user == null) return;

    await _db
        .from('users')
        .update({'fcm_token': token})
        .eq('id', user.uid);
  }
}
