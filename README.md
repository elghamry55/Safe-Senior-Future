# Safe Senior Future
### Flutter-Based Elderly Healthcare Monitoring & Family Assistance App

Safe Senior Future is the mobile application component of an integrated elderly-care project. It provides patients and family members with a shared interface for viewing health readings, managing medication schedules, and responding to emergency alerts.

**Project focus:** Flutter mobile development, real-time Firebase data, patient/family dashboards, medication reminders, and emergency notifications.

## Key Features

- **Patient and family experiences:** Separate patient and family flows. Family members can link to a patient using a patient ID.
- **Live health readings:** Displays heart rate, blood oxygen saturation (SpO2), and body temperature from Firebase Realtime Database.
- **Health history:** Stores changing vital readings in Cloud Firestore and Firebase Realtime Database.
- **Medication management:** Add, view, edit, and delete medication schedules; schedule recurring local reminders for selected days.
- **Emergency support:** Patient SOS requests are stored in Firestore and monitored by the family dashboard.
- **Fall-alert handling:** The family dashboard listens for incoming fall-alert records and can display an emergency screen with an alert message and confidence value.
- **Push and local notifications:** Firebase Cloud Messaging integration and high-priority local emergency notifications.
- **Personalized interface:** Arabic and English language switching, light/dark themes, and an onboarding flow.
- **Additional patient features:** Quran audio, audio books, and music screens.

## Tech Stack

| Area | Technologies |
| --- | --- |
| Framework | Flutter, Dart |
| State management | flutter_bloc (Cubit) |
| Backend & data | Firebase Core, Cloud Firestore, Firebase Realtime Database |
| Notifications | Firebase Cloud Messaging, flutter_local_notifications |
| Networking | Dio |
| Local storage | SharedPreferences |
| UI & experience | Material UI, flutter_screenutil, Lottie |
| Device features | Permission Handler, Audio Players, Flutter TTS |

## Architecture

The codebase is organized by feature, with UI, state management, and data access separated into dedicated folders.

    lib/
    ├── core/
    │   ├── services/       # Localization and notification services
    │   ├── theme/           # Theme state and configuration
    │   └── utils/
    ├── features/
    │   ├── auth/            # Patient and family registration flows
    │   ├── dashboard/       # Patient and family dashboards
    │   ├── emergency/       # SOS and fall-alert experiences
    │   ├── medication/      # Medication schedules and reminders
    │   └── entertainment/   # Quran, books, and audio
    ├── firebase_options.dart
    └── main.dart

## Firebase Data Integration

The Flutter app currently reads and writes the following data paths:

- Realtime Database: CurrentVitals for live readings and VitalsHistory for vital history.
- Cloud Firestore: patients, alerts, fall_alerts, and patient medication subcollections.
- Firebase Cloud Messaging: receives background messages and displays emergency notifications.

The live-vitals data is expected to include fields such as heartRate, SPO2, and temperature (or temp). Fall-alert records are consumed from the fall_alerts collection.

## Getting Started

### Requirements

- Flutter SDK compatible with the Dart constraint in pubspec.yaml (Dart SDK ^3.11.0).
- Android Studio or another Flutter-supported development environment.
- A Firebase project configured for the platforms you intend to run.

### Run locally

1. Clone this repository:
   
       git clone https://github.com/elghamry55/Safe-Senior-Future.git
       cd Safe-Senior-Future

2. Install dependencies:

       flutter pub get

3. Verify that lib/firebase_options.dart matches your own Firebase project configuration. If needed, regenerate the configuration with the FlutterFire CLI.
4. Configure the required Firebase services and secure Firestore/Realtime Database rules for your environment.
5. Run the app:

       flutter run

## Important Notes

- This repository documents the **Flutter application**. Hardware firmware, sensor setup, and any external fall-detection model or processing service must be configured separately if they are part of your complete system.
- Firebase client configuration is not a substitute for database security rules. Review and configure access rules before deploying or using real patient data.
- The app is an academic/demo project and is not a certified medical device. Health readings and alerts should not replace professional medical assessment.

## My Contribution

I worked on the Flutter mobile application, focusing on the patient and family user flows, dashboards, Firebase data integration, Cubit-based state management, medication scheduling, and emergency notification experiences.

---

**Built with Flutter and Firebase.**
