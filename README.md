# Wellet Connect

A Flutter companion app for care recipients (elderly parents, recovering patients). Wellet Connect runs on the care recipient's phone and syncs health data, medication confirmations, daily check-ins, and scanned documents back to the caregiver's Wellet web dashboard at [mywellet.com](https://mywellet.com).

## Features

- **Dashboard** — Today's health summary (steps, heart rate, sleep), sync status, check-in prompt, and recent medication confirmations
- **Medications** — View current medications, confirm with "Took it" or "Skipped" buttons, with haptic feedback and visual confirmation
- **Daily Check-in** — Simple "Good day / Not great / Need help" mood check-in (one per day)
- **Health Data Sync** — Reads from Apple HealthKit (iOS) and Health Connect (Android) via the `health` package
- **Offline-first** — Queues writes locally with drift (SQLite) and syncs when connectivity returns
- **Push Notifications** — Medication reminders, daily check-in reminders, and caregiver messages via Firebase Cloud Messaging
- **Real-time Updates** — Supabase real-time subscriptions so caregiver-added medications appear instantly

## Architecture

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart), cross-platform iOS + Android |
| Backend | Supabase (auth, database, real-time) |
| State management | Riverpod |
| Navigation | GoRouter with bottom navigation (3 tabs) |
| Health data | `health` package (HealthKit + Health Connect) |
| Offline queue | drift (SQLite) |
| Notifications | firebase_messaging + flutter_local_notifications |

## Design System

- **Primary color:** `#608F7C` (Wellet green)
- **Accent color:** `#3D6B58` (darker green)
- **Headings:** DM Serif Display (via Google Fonts)
- **Body text:** DM Sans (via Google Fonts)
- **Minimum font size:** 20sp (elderly-accessible)
- **Minimum touch target:** 56x56dp
- **Layout:** Left-aligned, high contrast (WCAG AA compliant)
- **Bottom navigation:** 3 tabs max (Home, Medications, Check-in)
- **Language:** "loved one" / "family member" — never "parent"

## Project Structure

```
lib/
├── main.dart                      # App entry point, initialization
├── app.dart                       # MaterialApp + GoRouter + bottom nav
├── config/
│   ├── supabase_config.dart       # Supabase URL and anon key
│   ├── theme.dart                 # Wellet theme (colors, typography)
│   └── constants.dart             # App-wide constants
├── models/
│   ├── vital.dart                 # Health reading model
│   ├── medication.dart            # Medication model
│   ├── medication_log.dart        # Medication confirmation log
│   ├── checkin_response.dart      # Daily check-in response
│   └── person.dart                # Person profile model
├── providers/
│   ├── auth_provider.dart         # Auth state + Supabase service
│   ├── health_provider.dart       # Health data state
│   ├── medication_provider.dart   # Medication list + logging
│   └── checkin_provider.dart      # Check-in state
├── services/
│   ├── supabase_service.dart      # Supabase API wrapper
│   ├── health_sync_service.dart   # HealthKit / Health Connect sync
│   ├── notification_service.dart  # FCM + local notifications
│   └── offline_queue_service.dart # drift SQLite offline queue
├── screens/
│   ├── login_screen.dart          # Email/password login
│   ├── dashboard_screen.dart      # Health summary + check-in prompt
│   ├── medications_screen.dart    # Medication list with actions
│   └── checkin_screen.dart        # Daily mood check-in
└── widgets/
    ├── vital_card.dart            # Health metric display card
    ├── medication_card.dart       # Medication with took/skipped buttons
    ├── checkin_button.dart        # Large mood button
    └── sync_status_indicator.dart # Synced / syncing / offline badge
```

## Getting Started

### Prerequisites

- Flutter 3.2+ with Dart 3.2+
- Xcode (for iOS) or Android Studio (for Android)
- Firebase project configured (for push notifications)

### Setup

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd wellet-connect
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate drift code (if modifying the offline queue schema):
   ```bash
   dart run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS and Android apps with bundle ID `com.wellet.welletConnect`
3. Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android)
4. Place them in `ios/Runner/` and `android/app/` respectively

### Health Data Permissions

- **iOS:** HealthKit entitlement must be enabled in Xcode. The app requests read-only access to steps, heart rate, blood pressure, blood oxygen, sleep, and weight.
- **Android:** Health Connect must be installed. Permissions are declared in `AndroidManifest.xml`.

## Supabase Tables

| Table | Purpose |
|-------|---------|
| `vitals` | Health readings (steps, heart rate, etc.) |
| `health_events` | Significant health events |
| `medications` | Medication list (read by app, managed by caregiver) |
| `medication_logs` | Confirmation logs (took/skipped) |
| `checkin_responses` | Daily mood check-ins |
| `people` | Person profiles linked to user accounts |

All queries are scoped to the authenticated user's `person_id` via Supabase Row Level Security (RLS).

## Language & Tone

- Simple, warm, reassuring language appropriate for elderly users
- BJ Fogg's Tiny Habits framework: never shame, anchor to existing behaviors
- Privacy-forward: "Your health information is encrypted and isolated with row-level security"
