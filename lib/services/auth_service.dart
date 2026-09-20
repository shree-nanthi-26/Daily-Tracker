import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth? _auth = FirebaseService.isInitialized ? FirebaseAuth.instance : null;

  // In-memory demo fallback user ID if Firebase is not yet provisioned
  static String demoUid = 'demo_user_001';

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth.authStateChanges();
    }
    // Return empty stream or null for fallback
    return Stream.value(null);
  }

  User? get currentUser {
    if (_auth != null) {
      return _auth.currentUser;
    }
    return null;
  }

  String get currentUserId {
    return _auth?.currentUser?.uid ?? demoUid;
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
    debugPrint('[AuthService] Operating in local demo mode (user: $demoUid)');
    return null;
  }

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    }
    debugPrint('[AuthService] Registered in local demo mode (user: $demoUid)');
    return null;
  }

  Future<UserCredential?> signInAnonymously() async {
    if (_auth != null) {
      return await _auth.signInAnonymously();
    }
    debugPrint('[AuthService] Operating in local demo mode (user: $demoUid)');
    return null;
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth.signOut();
    }
  }
}
