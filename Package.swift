// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "CaroDiario",
  defaultLocalization: "en",
  platforms: [.iOS(.v26)],
  products: [
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "HomeFeature",
      targets: ["HomeFeature"]
    ),
    .library(
      name: "LockScreenFeature",
      targets: ["LockScreenFeature"]
    ),
    .library(
      name: "SplashFeature",
      targets: ["SplashFeature"]
    ),
    .library(
      name: "OnboardingFeature",
      targets: ["OnboardingFeature"]
    ),
    .library(
      name: "AboutFeature",
      targets: ["AboutFeature"]
    ),
    .library(
      name: "AgreementsFeature",
      targets: ["AgreementsFeature"]
    ),
    .library(
      name: "AppearanceFeature",
      targets: ["AppearanceFeature"]
    ),
    .library(
      name: "ApplicationClient",
      targets: ["ApplicationClient"]
    ),
    .library(
      name: "Localizables",
      targets: ["Localizables"]
    ),
    .library(
      name: "Models",
      targets: ["Models"]
    ),
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]
    ),
    .library(
      name: "CameraFeature",
      targets: ["CameraFeature"]
    ),
    .library(
      name: "MicrophoneFeature",
      targets: ["MicrophoneFeature"]
    ),
    .library(
      name: "AVCaptureDeviceClient",
      targets: ["AVCaptureDeviceClient"]
    ),
    .library(
      name: "AVAudioSessionClient",
      targets: ["AVAudioSessionClient"]
    ),
    .library(
      name: "LanguageFeature",
      targets: ["LanguageFeature"]
    ),
    .library(
      name: "PDFKitClient",
      targets: ["PDFKitClient"]
    ),
    .library(
      name: "ExportFeature",
      targets: ["ExportFeature"]
    ),
    .library(
      name: "PDFPreviewFeature",
      targets: ["PDFPreviewFeature"]
    ),
    .library(
      name: "PasscodeFeature",
      targets: ["PasscodeFeature"]
    ),
    .library(
      name: "LocalAuthenticationClient",
      targets: ["LocalAuthenticationClient"]
    ),
    .library(
      name: "SettingsFeature",
      targets: ["SettingsFeature"]
    ),
    .library(
      name: "StoreKitClient",
      targets: ["StoreKitClient"]
    ),
    .library(
      name: "EntriesFeature",
      targets: ["EntriesFeature"]
    ),
    .library(
      name: "EntryDetailFeature",
      targets: ["EntryDetailFeature"]
    ),
    .library(
      name: "SQLiteDataClient",
      targets: ["SQLiteDataClient"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/sqlite-data", exact: "1.5.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.10.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", exact: "2.7.4"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.9"),
  ],
  targets: [
    .target(
      name: "SQLiteDataClient",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "Models"
      ],
      path: "Sources/Clients/SQLiteDataClient"
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem",
        "Localizables",
        "HomeFeature",
        "SplashFeature",
        "OnboardingFeature",
        "LockScreenFeature"
      ],
      path: "Sources/Features/AppFeature"
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem",
        "Localizables",
        "SettingsFeature"
      ],
      path: "Sources/Features/HomeFeature"
    ),
    .target(
      name: "LockScreenFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem",
        "Localizables",
        "LocalAuthenticationClient",
        "Models"
      ],
      path: "Sources/Features/LockScreenFeature"
    ),
    .target(
      name: "SplashFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem"
      ],
      path: "Sources/Features/SplashFeature"
    ),
    .testTarget(
      name: "SplashFeatureTests",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "TestHelper",
        "SplashFeature",
      ],
      path: "Tests/Features/SplashFeatureTests"
    ),
    .target(
      name: "TestHelper",
      dependencies: [
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      path: "Sources/Helpers/TestHelper"
    ),
    .target(
      name: "OnboardingFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem",
        "Localizables",
        "ApplicationClient"
      ],
      path: "Sources/Features/OnboardingFeature"
    ),
    .testTarget(
      name: "OnboardingFeatureTests",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "TestHelper",
        "OnboardingFeature",
      ],
      path: "Tests/Features/OnboardingFeatureTests"
    ),
    .target(
      name: "AboutFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables"
      ],
      path: "Sources/Features/AboutFeature"
    ),
    .target(
      name: "AgreementsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables"
      ],
      path: "Sources/Features/AgreementsFeature"
    ),
    .target(
      name: "AppearanceFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables",
        "EntriesFeature",
        "Models"
      ],
      path: "Sources/Features/AppearanceFeature",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "AboutFeatureTests",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "TestHelper",
        "AboutFeature",
      ],
      path: "Tests/Features/AboutFeatureTests"
    ),
    .target(
      name: "ApplicationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ],
      path: "Sources/Clients/ApplicationClient"
    ),
    .target(
      name: "Localizables",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Models"
      ],
      path: "Sources/Helpers/Localizables",
      resources: [.process("Resources")]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data")
      ]
    ),
    .target(
      name: "DesignSystem",
      dependencies: [],
      path: "Sources/Helpers/DesignSystem",
      resources: [.process("Resources")]
    ),
    .target(
      name: "CameraFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "AVCaptureDeviceClient",
        "DesignSystem",
        "Localizables",
        "Models"
      ],
      path: "Sources/Features/CameraFeature"
    ),
    .target(
      name: "MicrophoneFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "AVAudioSessionClient",
        "DesignSystem",
        "Localizables"
      ],
      path: "Sources/Features/MicrophoneFeature"
    ),
    .target(
      name: "AVCaptureDeviceClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "Models"
      ],
      path: "Sources/Clients/AVCaptureDeviceClient"
    ),
    .target(
      name: "AVAudioSessionClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "Models"
      ],
      path: "Sources/Clients/AVAudioSessionClient"
    ),
    .target(
      name: "LanguageFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables",
        "Models"
      ],
      path: "Sources/Features/LanguageFeature"
    ),
    .target(
      name: "ExportFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables",
        "Models",
        "PDFKitClient"
      ],
      path: "Sources/Features/ExportFeature"
    ),
    .target(
      name: "PDFKitClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "Models",
        "Localizables"
      ],
      path: "Sources/Clients/PDFKitClient"
    ),
    .target(
      name: "PDFPreviewFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DesignSystem",
        "Localizables",
      ],
      path: "Sources/Features/PDFPreviewFeature"
    ),
    .target(
      name: "PasscodeFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables",
        "Models",
        "LocalAuthenticationClient"
      ],
      path: "Sources/Features/PasscodeFeature"
    ),
    .target(
      name: "LocalAuthenticationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "Models",
      ],
      path: "Sources/Clients/LocalAuthenticationClient"
    ),
    .target(
      name: "StoreKitClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ],
      path: "Sources/Clients/StoreKitClient"
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AppearanceFeature",
        "ApplicationClient",
        "DesignSystem",
        "Localizables",
        "Models",
        "MicrophoneFeature",
        "AboutFeature",
        "AgreementsFeature",
        "CameraFeature",
        "ExportFeature",
        "LanguageFeature",
        "PasscodeFeature",
        "StoreKitClient",
        "LocalAuthenticationClient",
        "PDFPreviewFeature"
      ],
      path: "Sources/Features/SettingsFeature"
    ),
    .target(
      name: "EntriesFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "Localizables",
        "DesignSystem",
        "Models",
        "SQLiteDataClient",
        "EntryDetailFeature"
      ],
      path: "Sources/Features/EntriesFeature"
    ),
    .target(
      name: "EntryDetailFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "Localizables",
        "DesignSystem",
        "Models",
        "SQLiteDataClient"
      ],
      path: "Sources/Features/EntryDetailFeature"
    ),
  ]
)
