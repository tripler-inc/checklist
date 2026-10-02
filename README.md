# Checklist

A Flutter checklist app for managing daily tasks and reminders across mobile and desktop platforms.

## Features

- Add new checklist items
- Mark items complete or incomplete
- Edit an existing item inline via dialog
- Delete items with swipe-to-dismiss
- Reorder items with drag handles
- Persist tasks locally with SharedPreferences
- Toggle between light and dark theme
- Built with Flutter Material 3 design

## Tech Stack

- Flutter
- Dart
- SharedPreferences
- Material 3

## Project Structure

- lib/main.dart — app bootstrap
- lib/app.dart — app theme configuration and root MaterialApp
- lib/screens/checklist_screen.dart — checklist screen behavior and layout
- lib/widgets/ — reusable UI components
- lib/models/checklist_item.dart — checklist item model
- lib/repositories/ — persistence and theme storage logic
- test/widget_test.dart — widget tests for key flows

## Getting Started

### Prerequisites

- Flutter SDK installed and on your PATH
- A supported IDE such as VS Code or Android Studio

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run tests

```bash
flutter test
```

## Notes

The app stores checklist data locally using SharedPreferences so your items remain available after restarting the app. The theme preference is also persisted between launches.
