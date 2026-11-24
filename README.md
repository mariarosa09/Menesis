<p align="center">
  <img src="assets/images/menesheesh.png" alt="Mēnesis logo" width="160">
</p>

# Mēnesis

A Flutter menstrual-cycle tracker backed by Firebase. Users log their period,
see their current cycle phase and predictions, record daily symptoms, moods
and discharge, get possible reasons and remedy suggestions, and receive local
reminders.

## Features

- **Home**: greeting, current cycle day, phase ring (Menstruation, Fertile,
  Ovulation, Luteal, plus a Follicular overlay), countdown to the next period,
  and a button to start or end a period.
- **Calendar**: month view that colours period, fertile and ovulation days.
  Tap a day to see its log and note. Double-tap a day to open the daily log.
- **Daily log**: physical symptoms, mood, discharge type and notes for any past day.
- **Reasons & remedies**: explanations and self-care suggestions based on what
  was logged.
- **Smart prediction** (optional): averages the user's real cycle and period
  lengths to improve future predictions.
- **Profile & settings**: edit profile, cycle and period length, notifications,
  change email or password, clear data, delete account.
- **Reminders**: period approaching, fertile window or ovulation day, and a
  daily log reminder.

## Tech stack

| Area          | Package                                              |
|---------------|------------------------------------------------------|
| UI            | Flutter (Dart SDK `^3.11.0`), `convex_bottom_bar`     |
| Auth          | `firebase_auth`, `flutter_bloc` (`AuthCubit`)        |
| Database      | `cloud_firestore`                                    |
| Notifications | `flutter_local_notifications`, `timezone`, `app_settings` |

## Getting started

### Prerequisites

- Flutter SDK 3.41 or newer (stable channel)
- Android Studio or Xcode with an emulator or a device
- Access to the Firebase project `menesis-af6cc`, or your own Firebase project
  (see below)

### Run

The entry point is **`lib/registration/main.dart`**, not `lib/main.dart`, so
pass it with `-t`:

```bash
flutter pub get
flutter run -t lib/registration/main.dart
```

In VS Code, the configurations in `.vscode/launch.json` already point to
`lib/registration/main.dart`, so you can run with F5.

### Using your own Firebase project

The repo already contains `lib/firebase_options.dart` and
`android/app/google-services.json` for `menesis-af6cc`. To point the app at a
different project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then enable **Email/Password** sign-in in Firebase Authentication and create a
**Cloud Firestore** database.

## Project structure

```
lib/
├── registration/          # App entry (main.dart), splash, login, sign-up, initial setup
├── auth/                  # AuthCubit, AuthRepo (Firebase Auth + user doc), AppUser
├── services/
│   ├── cycle_repository.dart      # All cycle / log Firestore reads & writes
│   └── notification_service.dart  # Local reminder scheduling + preferences
├── app_navigation/
│   ├── tab1/              # Calendar, daily log, reasons, remedies
│   ├── tab2/              # Home page (cycle ring, period button)
│   └── tab3/
│       ├── profile/       # Profile, edit profile, cycle and period length
│       └── settings/      # Notifications, data & account, change email/password
├── otp.dart
└── firebase_options.dart
assets/
├── fonts/                 # CormorantGaramond, DMSans
└── images/                # Logo, cat animation frames, discharge/reason/remedy icons
```

## Firestore data model

```
users/{uid}
  username, email, first name, middle initial, last name, deleted?, deletedAt?
  ├── cycle/cycle info
  │     cycle type, cycle length, period length,
  │     status        (true = no period in progress, false = in progress)
  │     emptyRecord   (true until the first period is logged)
  │     smart prediction
  │     ├── periodLogs/{yyyy-MM-dd 00:00:00.000}
  │     │     cycle start date, period end date, cycle end date,
  │     │     fertile start date, fertile end date, ovulation date,
  │     │     cycle length, period length
  │     └── symptomsLogs/{yyyy-MM-dd 00:00:00.000}
  │           log date, physical symptoms[], mood[], discharge[], notes
  └── settings/notifications
        period approaching, fertile window, daily log   (bools)
```

### Prediction rules

When a period starts on day `S`, using the current cycle length `C` and period
length `P`:

- Period end = `S + P − 1`
- Cycle end = `S + C − 1`
- Fertile window = `S + C − 20` to `S + C − 14`
- Ovulation = the day before the fertile window ends

With **smart prediction** on:

- Starting a period rewrites the previous cycle's real length and refreshes the
  average cycle length.
- Ending a period records the real period length and refreshes the average
  period length.

## Data access

All cycle-related Firestore access goes through `CycleRepository`
(`lib/services/cycle_repository.dart`):

- **Typed models.** `CycleInfo` and `CycleRecord` parse documents safely. A
  missing field falls back to a default or skips that record, instead of
  throwing.
- **Live listeners.**
  - Home uses three: user doc, `cycle info`, and the latest `periodLogs` doc.
    Every derived value (phase, ring %, countdowns) is computed locally.
  - Calendar uses two: `cycle info` and `periodLogs`. The grid updates on its
    own after a period starts or ends.
  - Profile uses two: user doc and `cycle info`.
- **One read per day.** The calendar and the daily-log sheet each fetch a day's
  log once and reuse it, including for the Reasons and Remedies sheets.
- **Batched writes.** `startPeriod` and `endPeriod` read `cycle info` and
  `periodLogs` once each, compute the averages in memory, and commit every
  write in one `WriteBatch`.

## Notifications

`NotificationService` (`lib/services/notification_service.dart`) is set up in
`main()` and schedules:

| Reminder           | When                                             | Setting key          |
|--------------------|--------------------------------------------------|----------------------|
| Period approaching | 2 days before the predicted next period, 9:00 AM | `period approaching` |
| Fertile window     | First fertile day, and ovulation day, 9:00 AM    | `fertile window`     |
| Daily log          | Every day at 8:00 PM                             | `daily log`          |

Reminders are rebuilt in these cases:

- Home's cycle data changes: app open, period start or end from either screen.
- A toggle changes on the Notifications screen.

Reminders are cancelled on logout and on account deletion.

Platform notes:

- **Android:** `AndroidManifest.xml` declares `POST_NOTIFICATIONS`,
  `RECEIVE_BOOT_COMPLETED`, and the plugin's `ScheduledNotificationReceiver`
  and `ScheduledNotificationBootReceiver`. Without the receivers, scheduled
  notifications never fire. Reminders use inexact alarms, so no
  exact-alarm permission is needed. They may arrive a few minutes late.
- **Android 13+ and iOS:** the app asks for notification permission when the
  home screen opens, and again when a toggle is turned on.
- **Time zones:** reminders are scheduled by absolute time, so no time-zone
  name lookup is needed. After a daylight-saving change, the daily reminder is
  corrected the next time the app opens.

## Known limitations

- `test/widget_test.dart` is still the default Flutter template and doesn't
  test the app.
- **Clear Data** resets `cycle info` and the notification settings, but it
  doesn't delete existing `periodLogs` or `symptomsLogs`.
