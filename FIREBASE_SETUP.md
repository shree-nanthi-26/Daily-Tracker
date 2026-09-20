# Firebase & Cloud Firestore Setup Guide

This guide documents the configuration and activation of **Cloud Firestore** and **Firebase Authentication** for DailyWork Mobile.

## Project Information
- **Firebase Project ID**: `daily-work-tracker-e5831`
- **Package Name (Android)**: `com.example.daily_work_mobile`
- **Config File**: `android/app/google-services.json` (already configured)
- **Dart Options**: `lib/firebase_options.dart`

---

## 1. Enable Cloud Firestore in Firebase Console

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Select the project: **`daily-work-tracker-e5831`**.
3. In the left navigation sidebar under **Build**, click **Firestore Database**.
4. Click **Create database**.
5. Choose a Cloud Firestore location (e.g. `nam5 (us-central)` or your closest region).
6. Select **Production rules** (or Test mode while verifying).
7. Deploy the provided security rules from `firestore.rules`:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;

         match /{document=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```
8. Click **Publish**.

---

## 2. Enable Authentication Providers

1. In the Firebase Console left sidebar under **Build**, click **Authentication**.
2. Click **Get Started** if not already enabled.
3. In the **Sign-in method** tab, enable:
   - **Email/Password**: Turn on and save.
   - **Anonymous** (optional, for instant guest accounts).

---

## 3. Data Schema Overview

Each user has an isolated root document under `/users/{uid}` with 4 subcollections:

| Subcollection | Document ID | Description |
| :--- | :--- | :--- |
| `tasks` | `taskId` (UUID) | Task items, priority, due date, done status, category |
| `habits` | `habitId` (UUID) | Habit titles, categories, frequencies, reminder times, archive status |
| `habit_completions` | `{habitId}_{dateStr}` | Check-in logs with ISO date string and timestamp |
| `goals` | `goalId` (UUID) | Goals, targets, current progress values, categories |

---

## 4. Cross-Device Sync Workflow

1. **Guest Mode (Offline Default)**:
   - Users can create, edit, check in, and view habits, tasks, and goals completely offline using local persistence (`SharedPreferences`).
2. **Cloud Connect Sheet**:
   - In Settings -> **Cloud Sync & Cross-Device Hub**, users can tap **"Connect Cloud Account"** to sign in or register with email and password.
3. **One-Tap Migration**:
   - Tapping **"Sync to Cloud Now"** runs `syncLocalToCloud(uid)` which transfers all local data to Firestore in atomic batches.
4. **Real-Time Cross-Device Listening**:
   - When signed in, `streamTasks`, `streamHabits`, `streamCompletions`, and `streamGoals` listen to real-time Firestore snapshots with automatic offline cache fallback.
