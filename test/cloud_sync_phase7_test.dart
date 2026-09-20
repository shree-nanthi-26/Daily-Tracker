import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_work_mobile/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 7 Cloud Sync Preparation & In-Memory State Tests', () {
    test('FirestoreService initializes in clean state with empty collections when Firebase uninitialized', () {
      final service = FirestoreService();
      expect(service.isCloudActive, isFalse);
      expect(service.currentTasks, isEmpty);
      expect(service.currentHabits, isEmpty);
      expect(service.currentGoals, isEmpty);
    });

    test('prepareSyncPayload exports structured payload with all entities and summary', () {
      final service = FirestoreService();
      final payload = service.prepareSyncPayload();

      expect(payload.containsKey('tasks'), isTrue);
      expect(payload.containsKey('habits'), isTrue);
      expect(payload.containsKey('completions'), isTrue);
      expect(payload.containsKey('goals'), isTrue);
      expect(payload.containsKey('summary'), isTrue);

      final summary = payload['summary'] as Map<String, dynamic>;
      expect(summary['tasksCount'], 0);
      expect(summary['habitsCount'], 0);
      expect(summary['goalsCount'], 0);
      expect(summary['totalCount'], 0);
    });

    test('syncLocalToCloud throws StateError when Cloud Firestore is uninitialized', () async {
      final service = FirestoreService();
      expect(service.isCloudActive, isFalse);

      expect(
        () => service.syncLocalToCloud('test_user_uid'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Cloud Firestore is not active'),
        )),
      );
    });

    test('fetchCloudToLocal throws StateError when Cloud Firestore is uninitialized', () async {
      final service = FirestoreService();
      expect(service.isCloudActive, isFalse);

      expect(
        () => service.fetchCloudToLocal('test_user_uid'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Cloud Firestore is not active'),
        )),
      );
    });
  });

  group('Phase 7 Security Rules & Documentation Validation Tests', () {
    test('firestore.rules exists and specifies user-isolated read/write rules', () {
      final file = File('firestore.rules');
      expect(file.existsSync(), isTrue, reason: 'firestore.rules should exist in project root');

      final content = file.readAsStringSync();
      expect(content, contains("rules_version = '2';"));
      expect(content, contains("match /users/{userId}"));
      expect(content, contains("request.auth != null && request.auth.uid == userId"));
    });

    test('FIREBASE_SETUP.md exists and documents Firestore & Auth activation steps', () {
      final file = File('FIREBASE_SETUP.md');
      expect(file.existsSync(), isTrue, reason: 'FIREBASE_SETUP.md should exist in project root');

      final content = file.readAsStringSync();
      expect(content, contains('daily-work-tracker-e5831'));
      expect(content, contains('Enable Cloud Firestore'));
      expect(content, contains('Enable Authentication'));
      expect(content, contains('Cross-Device Sync'));
    });
  });
}
