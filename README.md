# BoxAllTV

## Overview
BoxAllTV is a Flutter application featuring Firebase integration, FTP uploads for reels, and in-app purchases via Stripe. It uses the GetX pattern for state management and MVC-like architecture.

## Architecture
The application follows a structured layered architecture utilizing GetX:
- **`lib/controllers/`**: Contains GetX controllers responsible for business logic, state management, and handling user interactions (e.g., cart processing, upload workflows).
- **`lib/services/`**: Houses integrations with external services such as Firebase, Stripe payment intents, and BunnyCDN FTP uploads.
- **`lib/views/`**: Contains the UI layers (screens, pages, and dialogs) that observe state changes from controllers.
- **`lib/widgets/`**: Reusable UI components.

## Prerequisites
- **Flutter SDK:** Version 3.19.0 or higher (Dart `>=3.3.4 <4.0.0`).
- **Firebase Project:** You must configure a Firebase project with Authentication, Firestore, and Storage.
- **Stripe Account:** Required for processing payments.
- **BunnyCDN:** FTP storage required for uploading media (reels).

## Environment Variables
The application requires the following environment variables to be passed at compile/run time via `--dart-define`.
A `.env.example` file is provided as a reference:
- `STRIPE_KEY`: Your Stripe secret key.
- `FTP_USER`: Your BunnyCDN FTP username.
- `FTP_PASS`: Your BunnyCDN FTP password.

## Install
Clone the repository and fetch dependencies:
```bash
flutter pub get
```

## Run
To run the app, you must supply the necessary environment variables. Replace the placeholder values with your actual credentials:
```bash
flutter run \
  --dart-define=STRIPE_KEY=your_stripe_key_here \
  --dart-define=FTP_USER=your_ftp_user_here \
  --dart-define=FTP_PASS=your_ftp_pass_here
```

## Test
To execute the test suite:
```bash
flutter test
```
Note: The unit and widget tests use a `fake_cloud_firestore` test harness located in `test/helpers/firebase_test_setup.dart`. This allows the tests to run fully offline in CI environments, without requiring real Firebase or Stripe credentials.

## Setup (Missing Configuration)
The repository does not include pre-configured `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) files. 
A fresh clone requires the developer to initialize their own Firebase project:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Firestore**, **Authentication**, and **Storage**.
3. Register an Android app and download `google-services.json`, placing it in `android/app/`.
4. Register an iOS app and download `GoogleService-Info.plist`, placing it in `ios/Runner/`.
5. Ensure your BunnyCDN FTP credentials and Stripe keys are ready.
