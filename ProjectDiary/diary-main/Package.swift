// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "diary-main",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
      
      // Schedulers
      
      .library(name: "BackgroundQueue", targets: ["BackgroundQueue"]),
      
        // Clients
        
        .library(
            name: "UserDefaultsClient",
            targets: ["UserDefaultsClient"]
        ),
        
        .library(
            name: "CoreDataClient",
            targets: ["CoreDataClient"]
        ),
        
        .library(
            name: "FileClient",
            targets: ["FileClient"]
        ),
        
        .library(
            name: "LocalAuthenticationClient",
            targets: ["LocalAuthenticationClient"]
        ),
        
        .library(
            name: "UIApplicationClient",
            targets: ["UIApplicationClient"]
        ),
        
        .library(
            name: "AVCaptureDeviceClient",
            targets: ["AVCaptureDeviceClient"]
        ),
        
        .library(
            name: "AVAudioPlayerClient",
            targets: ["AVAudioPlayerClient"]
        ),
        
        .library(
            name: "AVAudioRecorderClient",
            targets: ["AVAudioRecorderClient"]
        ),
        
        .library(
            name: "AVAudioSessionClient",
            targets: ["AVAudioSessionClient"]
        ),
        
        .library(
            name: "AVAssetClient",
            targets: ["AVAssetClient"]
        ),
        
        .library(
            name: "FeedbackGeneratorClient",
            targets: ["FeedbackGeneratorClient"]
        ),
        
        .library(
            name: "StoreKitClient",
            targets: ["StoreKitClient"]
        ),
        
        .library(
            name: "PDFKitClient",
            targets: ["PDFKitClient"]
        ),
        
        // Features
        
        // App
        
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        
        
        // Clip
        
        .library(
            name: "ClipFeature",
            targets: ["ClipFeature"]
        ),
        
        // Entries
        
        .library(
            name: "AddEntryFeature",
            targets: ["AddEntryFeature"]
        ),
        .library(
            name: "AttachmentsFeature",
            targets: ["AttachmentsFeature"]
        ),
        .library(
            name: "AudioPickerFeature",
            targets: ["AudioPickerFeature"]
        ),
        .library(
            name: "AudioRecordFeature",
            targets: ["AudioRecordFeature"]
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
            name: "ImagePickerFeature",
            targets: ["ImagePickerFeature"]
        ),
        .library(
            name: "SearchFeature",
            targets: ["SearchFeature"]
        ),
        
        // Home
        
        .library(
            name: "HomeFeature",
            targets: ["HomeFeature"]
        ),
        
        // LockScreen
        
        .library(
            name: "LockScreenFeature",
            targets: ["LockScreenFeature"]
        ),
        
        // Onboarding
        
        .library(
            name: "OnboardingFeature",
            targets: ["OnboardingFeature"]
        ),
        
        // Root
        
        .library(
            name: "RootFeature",
            targets: ["RootFeature"]
        ),
        
        // Settings
        
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
            name: "CameraFeature",
            targets: ["CameraFeature"]
        ),
        .library(
            name: "ExportFeature",
            targets: ["ExportFeature"]
        ),
        .library(
            name: "LanguageFeature",
            targets: ["LanguageFeature"]
        ),
        .library(
            name: "MicrophoneFeature",
            targets: ["MicrophoneFeature"]
        ),
        .library(
            name: "PasscodeFeature",
            targets: ["PasscodeFeature"]
        ),
        .library(
            name: "PDFPreviewFeature",
            targets: ["PDFPreviewFeature"]
        ),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]
        ),
        
        // Splash
        
        .library(
            name: "SplashFeature",
            targets: ["SplashFeature"]
        ),
        
        // Helpers
        
        .library(
            name: "Styles",
            targets: ["Styles"]
        ),
        .library(
            name: "SwiftHelper",
            targets: ["SwiftHelper"]
        ),
        .library(
            name: "SwiftUIHelper",
            targets: ["SwiftUIHelper"]
        ),
        .library(
            name: "Views",
            targets: ["Views"]
        ),
        .library(
            name: "Localizables",
            targets: ["Localizables"]
        ),
        
        // Models
        
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.55.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.11.1"),
    ],
    targets: [
      
      // Schedulers
      
      .target(
        name: "BackgroundQueue",
        dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    ],
        path: "Sources/Clients/BackgroundQueue"
      ),
        // Clients
        
        .target(
            name: "AVAssetClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Clients/AVAssetClient"
        ),
        
        .target(
            name: "AVAudioPlayerClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Clients/AVAudioPlayerClient"
        ),
        
        .target(
            name: "AVAudioRecorderClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Clients/AVAudioRecorderClient"
        ),
        
        .target(
            name: "AVAudioSessionClient",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              "Models"
        ],
            path: "Sources/Clients/AVAudioSessionClient"
        ),
        
        .target(
            name: "AVCaptureDeviceClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "Models"
        ],
            path: "Sources/Clients/AVCaptureDeviceClient"
        ),

        .target(
            name: "CoreDataClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models"
            ],
            path: "Sources/Clients/CoreDataClient"
        ),
        
        .target(
            name: "FeedbackGeneratorClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Clients/FeedbackGeneratorClient"
        ),
        
        .target(
            name: "FileClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "Models")
            ],
            path: "Sources/Clients/FileClient"
        ),
        
        .target(
            name: "LocalAuthenticationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models"
            ],
            path: "Sources/Clients/LocalAuthenticationClient"
        ),
        
        .target(
            name: "PDFKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models"
            ],
            path: "Sources/Clients/PDFKitClient"
        ),
        
        .target(
            name: "StoreKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Clients/StoreKitClient"
        ),
        
        .target(
            name: "UIApplicationClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Clients/UIApplicationClient"
        ),
        
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models"
            ],
            path: "Sources/Clients/UserDefaultsClient"
        ),
        
        // App
        
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SplashFeature",
                "OnboardingFeature",
                "HomeFeature",
                "LockScreenFeature",
                "AVCaptureDeviceClient",
                "FeedbackGeneratorClient",
                "SearchFeature",
                "AVAudioSessionClient",
                "UserDefaultsClient",
                "CoreDataClient",
                "FileClient",
                "LocalAuthenticationClient",
                "UIApplicationClient",
                "StoreKitClient",
                "PDFKitClient"
            ],
            path: "Sources/Features/AppFeature"
        ),
        
        // Clip
        
        .target(
            name: "ClipFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SplashFeature",
                "OnboardingFeature",
            ],
            path: "Sources/Features/ClipFeature"
        ),
        
        // Entries
        
        .target(
            name: "AddEntryFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "ImagePickerFeature",
                "Views",
                "Localizables",
                "AVCaptureDeviceClient",
                "AttachmentsFeature",
                "UIApplicationClient",
                "AudioPickerFeature",
                "AVAudioRecorderClient",
                "AVAudioSessionClient",
                "AVAudioPlayerClient",
                "AudioRecordFeature",
                "AVAssetClient",
                "BackgroundQueue"
            ],
            path: "Sources/Features/Entries/AddEntryFeature"
        ),
        
        .target(
            name: "AttachmentsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "Views",
                "Models",
                "Localizables",
                "AVAudioPlayerClient",
                "UIApplicationClient",
                "SwiftHelper",
                "BackgroundQueue"
            ],
            path: "Sources/Features/Entries/AttachmentsFeature"
        ),
        
        .target(
            name: "AudioPickerFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Features/Entries/AudioPickerFeature"
        ),

        .target(
            name: "AudioRecordFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "FileClient",
                "AVAudioRecorderClient",
                "AVAudioSessionClient",
                "AVAudioPlayerClient",
                "Views",
                "UIApplicationClient",
                "Localizables",
                "SwiftHelper"
            ],
            path: "Sources/Features/Entries/AudioRecordFeature"
        ),
        
        .target(
            name: "EntriesFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "CoreDataClient",
                "EntryDetailFeature",
                "AddEntryFeature",
                "Localizables",
                "AVCaptureDeviceClient"
            ],
            path: "Sources/Features/Entries/EntriesFeature"
        ),
        
        .target(
            name: "EntryDetailFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "Styles",
                "Views",
                "Localizables",
                "AVCaptureDeviceClient",
                "AttachmentsFeature",
                "UIApplicationClient",
                "AddEntryFeature"
            ],
            path: "Sources/Features/Entries/EntryDetailFeature"
        ),
        
        .target(
            name: "ImagePickerFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Features/Entries/ImagePickerFeature"
        ),
        
        .target(
            name: "SearchFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "EntriesFeature",
                "CoreDataClient",
                "UIApplicationClient",
                "AVCaptureDeviceClient",
                "FileClient",
                "BackgroundQueue"
            ],
            path: "Sources/Features/Entries/SearchFeature"
        ),
        
        // Home
        
        .target(
            name: "HomeFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Styles",
                "UserDefaultsClient",
                "CoreDataClient",
                "FileClient",
                "EntriesFeature",
                "SettingsFeature",
                "AddEntryFeature",
                "AVCaptureDeviceClient",
                "FeedbackGeneratorClient",
                "AVAudioSessionClient",
                "SearchFeature",
                "StoreKitClient",
                "PDFKitClient"
            ],
            path: "Sources/Features/HomeFeature"
        ),
        
        // LockScreen
        
        .target(
            name: "LockScreenFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Styles",
                "Views",
                "UserDefaultsClient",
                "LocalAuthenticationClient",
                "Localizables"
            ],
            path: "Sources/Features/LockScreenFeature"
        ),
        
        // Onboarding
        
        .target(
            name: "OnboardingFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "Styles",
                "Views",
                "EntriesFeature",
                "FeedbackGeneratorClient"
            ],
            path: "Sources/Features/OnboardingFeature"
        ),
        
        // Root
        
        .target(
            name: "RootFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AppFeature",
                "AVCaptureDeviceClient",
                "AVAudioSessionClient",
                "UserDefaultsClient",
                "CoreDataClient",
                "FileClient",
                "LocalAuthenticationClient",
                "HomeFeature",
                "Styles",
                "UIApplicationClient",
                "FeedbackGeneratorClient",
                "StoreKitClient",
                "PDFKitClient"
            ],
            path: "Sources/Features/RootFeature"
        ),
        
        // Settings
        
        .target(
            name: "AboutFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UIApplicationClient",
                "Localizables",
                "Styles",
                "Views"
            ],
            path: "Sources/Features/Settings/AboutFeature"
        ),
        .target(
            name: "AgreementsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UIApplicationClient",
                "Localizables",
                "Views"
            ],
            path: "Sources/Features/Settings/AgreementsFeature"
        ),
        .target(
            name: "AppearanceFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UIApplicationClient",
                "Localizables",
                "Views",
                "UserDefaultsClient",
                "FeedbackGeneratorClient",
                "Styles",
                "EntriesFeature",
                "SwiftUIHelper"
            ],
            path: "Sources/Features/Settings/AppearanceFeature",
            resources: [.process("Resources")]
        ),
        .target(
            name: "CameraFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AVCaptureDeviceClient",
                "UIApplicationClient",
                "FeedbackGeneratorClient",
                "Styles",
                "Localizables"
            ],
            path: "Sources/Features/Settings/CameraFeature"
        ),
        .target(
            name: "ExportFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Views",
                "Localizables",
                "UIApplicationClient",
                "PDFKitClient",
                "PDFPreviewFeature",
                "CoreDataClient",
                "FileClient",
                "Models"
            ],
            path: "Sources/Features/Settings/ExportFeature"
        ),
        .target(
            name: "LanguageFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Views",
                "Localizables",
                "Styles",
                "Models",
                "UserDefaultsClient"
            ],
            path: "Sources/Features/Settings/LanguageFeature"
        ),
        .target(
            name: "MicrophoneFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UIApplicationClient",
                "FeedbackGeneratorClient",
                "AVAudioSessionClient",
                "Localizables",
                "Styles",
                "Views"
            ],
            path: "Sources/Features/Settings/MicrophoneFeature"
        ),
        .target(
            name: "PasscodeFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "LocalAuthenticationClient",
                "UserDefaultsClient",
                "Styles",
                "Views",
                "Localizables",
                "SwiftUIHelper"
            ],
            path: "Sources/Features/Settings/PasscodeFeature"
        ),
        .target(
            name: "PDFPreviewFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PDFKitClient",
                "Views"
            ],
            path: "Sources/Features/Settings/PDFPreviewFeature"
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PasscodeFeature",
                "UserDefaultsClient",
                "UIApplicationClient",
                "AVCaptureDeviceClient",
                "LocalAuthenticationClient",
                "FeedbackGeneratorClient",
                "EntriesFeature",
                "AVAudioSessionClient",
                "StoreKitClient",
                "PDFKitClient",
                "PDFPreviewFeature",
                "MicrophoneFeature",
                "AboutFeature",
                "AgreementsFeature",
                "AppearanceFeature",
                "CameraFeature",
                "ExportFeature",
                "LanguageFeature",
                "SwiftUIHelper"
            ],
            path: "Sources/Features/Settings/SettingsFeature"
        ),
        
        // Splash
        
        .target(
            name: "SplashFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "Styles"
            ],
            path: "Sources/Features/SplashFeature"
        ),
        
        // Helpers
        
        .target(
            name: "Styles",
            dependencies: [],
            path: "Sources/Helpers/Styles",
            resources: [.process("Fonts")]
        ),
        
        .target(
            name: "Views",
            dependencies: [
                "Styles",
                "SwiftUIHelper"
            ],
            path: "Sources/Helpers/Views"
        ),
        
        .target(
            name: "SwiftHelper",
            dependencies: [],
            path: "Sources/Helpers/SwiftHelper"
        ),
        
        .target(
            name: "SwiftUIHelper",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Helpers/SwiftUIHelper"
        ),
        
        .target(
            name: "Localizables",
            dependencies: [],
            path: "Sources/Helpers/Localizables",
            resources: [.process("Resources")]
        ),
        
        // Models
        
        .target(
            name: "Models",
            dependencies: [],
            path: "Sources/Models"
        ),
        
        // Tests
        
        // Features
        
        // AppFeature
        
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"],
            path: "Tests/Features/AppFeatureTests"
        ),
        
        // Entries
        
        .testTarget(
            name: "AddEntryFeatureTests",
            dependencies: ["AddEntryFeature"],
            path: "Tests/Features/Entries/AddEntryFeatureTests"
        ),
        .testTarget(
            name: "AttachmentsFeatureTests",
            dependencies: ["AttachmentsFeature"],
            path: "Tests/Features/Entries/AttachmentsFeatureTests"
        ),
        .testTarget(
            name: "AudioRecordFeatureTests",
            dependencies: ["AudioRecordFeature"],
            path: "Tests/Features/Entries/AudioRecordFeatureTests"
        ),
        .testTarget(
            name: "EntriesFeatureTests",
            dependencies: ["EntriesFeature"],
            path: "Tests/Features/Entries/EntriesFeatureTests"
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: ["SearchFeature"],
            path: "Tests/Features/Entries/SearchFeatureTests"
        ),
        
        // Home
        
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"],
            path: "Tests/Features/HomeFeatureTests"
        ),
        
        // LockScreen
        
        .testTarget(
            name: "LockScreenFeatureTests",
            dependencies: ["LockScreenFeature"],
            path: "Tests/Features/LockScreenFeatureTests"
        ),
        
        // Onboarding
        
        .testTarget(
            name: "OnboardingFeatureTests",
            dependencies: ["OnboardingFeature"],
            path: "Tests/Features/OnboardingFeatureTests"
        ),
        
        // Root
        
        .testTarget(
            name: "RootFeatureTests",
            dependencies: ["RootFeature"],
            path: "Tests/Features/RootFeatureTests"
        ),
        
        // Settings
        
        .testTarget(
            name: "AboutFeatureTests",
            dependencies: [
                "AboutFeature",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/Features/Settings/AboutFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        
        .testTarget(
            name: "AgreementsFeatureTests",
            dependencies: [
                "AgreementsFeature",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/Features/Settings/AgreementsFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        
        .testTarget(
            name: "AppearanceFeatureTests",
            dependencies: [
                "AppearanceFeature",
                "EntriesFeature",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/Features/Settings/AppearanceFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "CameraFeatureTests",
            dependencies: [
                "CameraFeature",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/Features/Settings/CameraFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "PasscodeFeatureTests",
            dependencies: ["PasscodeFeature"],
            path: "Tests/Features/Settings/PasscodeFeatureTests"
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: ["SettingsFeature"],
            path: "Tests/Features/Settings/SettingsFeatureTests"
        ),
        
        // Splash
        
        .testTarget(
            name: "SplashFeatureTests",
            dependencies: ["SplashFeature"],
            path: "Tests/Features/SplashFeatureTests"
        ),
    ]
)
