# CaroDiario

CaroDiario is an iOS personal journal app built with SwiftUI and the Composable Architecture. It focuses on writing daily entries, attaching media, customizing the reading experience, and protecting private content with passcode and biometric access.

## Overview

The project is organized as a modular Swift Package with an Xcode app target in `App/CaroDiario.xcodeproj`. Most product logic lives under `Sources/` as independent feature and client modules.

Main app flow:

- Splash screen
- Optional lock screen
- First-run onboarding
- Home tabs for entries and settings

Core capabilities implemented in the codebase:

- Create, edit, browse, and delete diary entries
- Group entries by day
- Attach images and videos to entries
- Export and preview PDFs
- Configure passcode and local authentication
- Customize appearance with theme, layout, style, and app icon options
- Change app language between English, Spanish, Catalan, and Galician
- Review legal/about screens and App Store review prompt hooks

## Tech Stack

- Swift 6.2 package manifest
- SwiftUI for UI
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) for state management and navigation
- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) for dependency injection
- [sqlite-data](https://github.com/pointfreeco/sqlite-data) for persistence and queries
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) for UI snapshot coverage

## Project Structure

```text
App/
  CaroDiario.xcodeproj      Xcode project for running the iOS app
  CaroDiario/               App entry point and assets

Sources/
  Features/                 User-facing flows and screens
  Clients/                  Side-effect and platform integrations
  Models/                   Domain models and settings
  Helpers/DesignSystem/     Shared styles, fonts, buttons, and view helpers
  Helpers/Localizables/     Localized strings

Tests/
  Features/                 Reducer and snapshot tests per feature
```

Notable modules:

- `AppFeature`: root flow and scene switching
- `HomeFeature`: main tab container
- `EntriesFeature`: list of grouped entries
- `EntryDetailFeature`: entry editing and attachment handling
- `SettingsFeature`: appearance, language, export, permissions, about, and passcode flows
- `SQLiteDataClient`: database bootstrap and migrations

## Data and Persistence

Entries are stored in SQLite using `sqlite-data`. The live database is created in the app's documents directory as `db.sqlite`.

Related persisted data includes:

- `entries`: journal content and timestamps
- `assets`: attachment metadata
- `entryAssets`: relation between entries and attachments
- `user-settings.json`: user preferences stored in the documents directory

## Running the App

1. Open [App/CaroDiario.xcodeproj](/Users/agescura/Development/CaroDiario/App/CaroDiario.xcodeproj) in Xcode.
2. Select the `CaroDiario` app scheme.
3. Run on an iPhone simulator or device.

## Testing

Feature tests live in [Tests](/Users/agescura/Development/CaroDiario/Tests) and cover reducers plus snapshot-based UI checks for several screens.

Typical commands:

```bash
xcodebuild test -project App/CaroDiario.xcodeproj -scheme CaroDiario -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Current Caveat

At the time this README was written, package resolution fails because [Package.swift](/Users/agescura/Development/CaroDiario/Package.swift) enables the trait `ComposableArchitecture2DeprecationOverloads`, while the resolved `swift-composable-architecture` package only declares `ComposableArchitecture2Deprecations`.

Until that manifest mismatch is fixed, `xcodebuild` and Xcode package resolution may fail before the app can build.

## Why This Structure

This repository is set up to keep product code modular and testable:

- features are isolated by user flow
- side effects are abstracted behind clients
- shared UI concerns live in a lightweight design system
- models and settings are reusable across features

That makes it easier to evolve the app without pushing all logic into the app target.
