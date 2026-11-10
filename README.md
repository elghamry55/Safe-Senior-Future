# Safe Senior Future

## Flutter-Based Elderly Healthcare Monitoring & Family Assistance App

Safe Senior Future is the Flutter mobile application developed as part of an integrated elderly-care system. It provides patients and their family members with a shared platform for monitoring vital signs, managing medication schedules, and responding to emergency events.

**Project focus:** Flutter mobile development, Firebase integration, patient and family dashboards, medication management, and emergency notifications.

## Overview

The application supports two main user experiences: patients and family members. Patients can access their health information, manage medication schedules, and send emergency requests. Family members can monitor linked patients, follow health readings, and receive alerts that may require attention.

## Key Features

### Patient and Family Accounts
- Separate patient and family registration and application flows.
- Family members can connect to a patient account using a patient ID.
- Dedicated dashboards tailored to each user type.

### Health Monitoring
- Displays live heart rate, blood oxygen saturation (SpO2), and body temperature readings.
- Retrieves current readings from Firebase Realtime Database.
- Stores and accesses historical vital-sign data through Firebase services.

### Medication Management
- Add, view, edit, and delete medication schedules.
- Configure recurring reminders for selected days.
- Schedule local notifications to help patients follow their medication plans.

### Emergency Assistance
- Patients can send SOS requests that are stored in Cloud Firestore.
- Family dashboards monitor emergency requests.
- Supports incoming fall-alert records, including an alert message and confidence value.
- Integrates Firebase Cloud Messaging and high-priority local notifications for emergency-related updates.

### Personalization and Accessibility
- Arabic and English language support.
- Light and dark themes.
- Onboarding experience for new users.

### Additional Patient Features
- Quran audio.
- Audiobooks.
- Music screens.

## Technology Stack

| Area | Technologies |
| --- | --- |
| Framework and language | Flutter, Dart |
| State management | flutter_bloc (Cubit) |
| Backend and database | Firebase Core, Cloud Firestore, Firebase Realtime Database |
| Push notifications | Firebase Cloud Messaging (FCM) |
| Local notifications | flutter_local_notifications |
| Networking | Dio |
| Local storage | SharedPreferences |
| UI and animations | Material Design, flutter_screenutil, Lottie |
| Device and media features | permission_handler, audioplayers, Flutter TTS |

## Application Architecture

The project is organized by feature, keeping presentation, state management, and data-related responsibilities separated to support maintainability and future development.

A high-level overview of the Flutter application structure:

```text
lib/
├── core/
│   ├── services/          # Localization and notification services
│   ├── theme/             # Theme configuration and state
│   └── utils/             # Shared utilities
├── features/
│   ├── auth/              # Patient and family authentication flows
│   ├── dashboard/         # Patient and family dashboards
│   ├── emergency/         # SOS and fall-alert handling
│   ├── medication/        # Medication schedules and reminders
│   └── entertainment/     # Quran, audiobooks, and audio features
├── firebase_options.dart
└── main.dart
```

## Firebase Integration

The mobile application integrates with Firebase services to exchange and manage patient-related data.

| Firebase Service | Usage |
| --- | --- |
| Firebase Realtime Database | Reads live readings from `CurrentVitals` and vital history from `VitalsHistory`. |
| Cloud Firestore | Manages patient records, SOS alerts, fall-alert records, and medication subcollections. |
| Firebase Cloud Messaging | Receives push messages, including background notifications. |

### Data Structure Notes

- Live vital readings are expected to include fields such as `heartRate`, `SPO2`, and `temperature` (or `temp`).
- Fall-alert events are consumed from the `fall_alerts` collection.
- Patient-related records and medication data are stored in Cloud Firestore.

The exact database structure and security rules should match the Firebase project configured for the deployment environment.

## Getting Started

### Prerequisites

Before running the application, make sure you have:

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml` (`^3.11.0`).
- Android Studio, VS Code, or another Flutter-supported IDE.
- An Android emulator or a physical device.
- A Firebase project configured for the platform you want to run.

### Installation and Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/elghamry55/Safe-Senior-Future.git
   ```

2. Navigate to the project directory:

   ```bash
   cd Safe-Senior-Future
   ```

3. Install the project dependencies:

   ```bash
   flutter pub get
   ```

4. Configure Firebase:
   - Make sure `lib/firebase_options.dart` contains the configuration for your Firebase project.
   - If required, regenerate the configuration using the FlutterFire CLI.
   - Enable and configure the Firebase services used by the application.

5. Review and configure Firestore and Realtime Database security rules for your environment.

6. Run the application:

   ```bash
   flutter run
   ```

## My Contribution

I was responsible for the Flutter mobile application as part of the integrated elderly-care project. My work focused on:

- Developing patient and family user flows and dashboards.
- Integrating Firebase services for health data and emergency events.
- Implementing Cubit-based state management.
- Building medication scheduling and local reminder functionality.
- Integrating push and local notifications for emergency updates.
- Developing the mobile interfaces for health monitoring and patient assistance.

## Important Notes

- This repository covers the **Flutter mobile application**. Hardware firmware, sensor configuration, and any external fall-detection model or processing service are separate components of the complete system.
- Firebase client configuration alone does not secure application data. Configure and test appropriate Firestore and Realtime Database security rules before deployment.
- This is an academic and demonstration project, not a certified medical device. Its readings and alerts are not a substitute for professional medical assessment.

---

**Developed with Flutter and Firebase.**

**Mahmoud Elghamry**  
Flutter Developer

[GitHub Profile](https://github.com/elghamry55)
