import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Object? _initError;
  static Object? get initError => _initError;

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await _initializeWeb();
      } else {
        await _initializeMobile();
      }
      _isInitialized = true;
      _initError = null;
      debugPrint('[FirebaseService] Firebase and Firestore initialized successfully for ${kIsWeb ? "Web" : defaultTargetPlatform.name}.');
    } catch (e, stackTrace) {
      _isInitialized = false;
      _initError = e;
      debugPrint('[FirebaseService] ⚠️ Firebase initialization error: $e');
      debugPrint('[FirebaseService] Stack trace:\n$stackTrace');
      debugPrint('[FirebaseService] Running with demo/offline fallback store.');
    }
  }

  /// Mobile (Android / iOS) Firebase initialization
  static Future<void> _initializeMobile() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore offline persistence for mobile
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Web Firebase initialization
  static Future<void> _initializeWeb() async {
    if (!DefaultFirebaseOptions.isWebConfigured) {
      throw StateError(
        'Firebase Web configuration is incomplete in lib/firebase_options.dart.\n'
        'To connect Firebase on Web:\n'
        '  1. Open Firebase Console (https://console.firebase.google.com/) -> Project "daily-work-tracker-e5831"\n'
        '  2. Project Settings -> General -> "Your apps" -> Add Web app ("</>")\n'
        '  3. Copy the apiKey and appId into DefaultFirebaseOptions.web in lib/firebase_options.dart.\n'
        'Until configured, the web app will run using the offline/demo fallback store.',
      );
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      // Enable Firestore persistence on web
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (settingsError) {
      debugPrint('[FirebaseService] Notice: Could not apply Web Firestore settings: $settingsError');
    }
  }
}
