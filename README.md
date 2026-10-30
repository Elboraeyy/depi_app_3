# DEPI Workspace

Flutter application for the DEPI Firebase task. It combines the shared requirements from the reference projects in one small, organized app:

- Firebase Authentication with email/password registration, login, email verification, resend verification, and logout.
- Cloud Firestore student CRUD: add, list, edit, and delete students.
- Cloud Firestore task CRUD: add, list, edit, delete, complete/uncomplete, and due dates.
- Cubit state management with a simple feature-based structure.
- User-scoped data under `users/{uid}/students` and `users/{uid}/tasks`.

## Firebase setup

The Android app is configured for the existing DEPI Firebase project `depi-1-60ebd`. Enable **Email/Password** in Firebase Authentication and create the Firestore database in the Firebase console before testing sign-up and data operations.

The app uses the Firebase files in `android/app/google-services.json` and `lib/firebase_options.dart`. If a different Firebase project is needed, run:

```bash
flutterfire configure
```

Then replace the Firestore rules with the rules in `firestore.rules` and deploy them from the Firebase CLI.

## Run

```bash
flutter pub get
flutter run
```

On this Windows machine, the ready-to-run command is:

```powershell
.\tool\run_android.ps1
```

It prepares the same-drive Pub cache, Android JDK, short Gradle temp path, and starts the running `emulator-5554`.

## Structure

```text
lib/
  auth_cubit/       Firebase Authentication and states
  home/cubit/       Student CRUD Cubit and states
  tasks/cubit/      Task CRUD Cubit and states
  models/           Firestore models
  screens/          Authentication and workspace screens
```
