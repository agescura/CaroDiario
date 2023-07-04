// swift-tools-version:5.7

import PackageDescription

let composableArchitecture: Target.Dependency = .product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
)
let dependencies: Target.Dependency = .product(
    name: "Dependencies",
    package: "swift-dependencies"
)
let snapshotTesting: Target.Dependency = .product(
    name: "SnapshotTesting",
    package: "swift-snapshot-testing"
)

let package = Package(
    name: "diary-main",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        // Clients
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "CoreDataClient", targets: ["CoreDataClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "LocalAuthenticationClient", targets: ["LocalAuthenticationClient"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "AVCaptureDeviceClient", targets: ["AVCaptureDeviceClient"]),
        .library(name: "AVAudioPlayerClient", targets: ["AVAudioPlayerClient"]),
        .library(name: "AVAudioRecorderClient", targets: ["AVAudioRecorderClient"]),
        .library(name: "AVAudioSessionClient", targets: ["AVAudioSessionClient"]),
        .library(name: "AVAssetClient", targets: ["AVAssetClient"]),
        .library(name: "FeedbackGeneratorClient", targets: ["FeedbackGeneratorClient"]),
        .library(name: "StoreKitClient", targets: ["StoreKitClient"]),
        .library(name: "PDFKitClient", targets: ["PDFKitClient"]),
        // Features
        // App
        .library(name: "AppFeature", targets: ["AppFeature"]),
        // Clip
        .library(name: "ClipFeature", targets: ["ClipFeature"]),
        // Entries
        .library(name: "AddEntryFeature", targets: ["AddEntryFeature"]),
        .library(name: "AttachmentsFeature", targets: ["AttachmentsFeature"]),
        .library(name: "AudioPickerFeature", targets: ["AudioPickerFeature"]),
        .library(name: "AudioRecordFeature", targets: ["AudioRecordFeature"]),
        .library(name: "EntriesFeature", targets: ["EntriesFeature"]),
        .library(name: "EntryDetailFeature", targets: ["EntryDetailFeature"]),
        .library(name: "ImagePickerFeature", targets: ["ImagePickerFeature"]),
        .library(name: "SearchFeature", targets: ["SearchFeature"]),
        // Home
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        // LockScreen
        .library(name: "LockScreenFeature", targets: ["LockScreenFeature"]),
        // Onboarding
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
        // Root
        .library(name: "RootFeature", targets: ["RootFeature"]),
        // Settings
        .library(name: "AboutFeature", targets: ["AboutFeature"]),
        .library(name: "AgreementsFeature", targets: ["AgreementsFeature"]),
        .library(name: "AppearanceFeature", targets: ["AppearanceFeature"]),
        .library(name: "CameraFeature", targets: ["CameraFeature"]),
        .library(name: "ExportFeature", targets: ["ExportFeature"]),
        .library(name: "LanguageFeature", targets: ["LanguageFeature"]),
        .library(name: "MicrophoneFeature", targets: ["MicrophoneFeature"]),
        .library(name: "PasscodeFeature", targets: ["PasscodeFeature"]),
        .library(name: "PDFPreviewFeature", targets: ["PDFPreviewFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        // Splash
        .library(name: "SplashFeature", targets: ["SplashFeature"]),
        // Helpers
        .library(name: "Styles", targets: ["Styles"]),
        .library(name: "SwiftHelper", targets: ["SwiftHelper"]),
        .library(name: "SwiftUIHelper", targets: ["SwiftUIHelper"]),
        .library(name: "Views", targets: ["Views"]),
        .library(name: "Localizables", targets: ["Localizables"]),
        // Models
        .library(name: "Models", targets: ["Models"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.54.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.11.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "0.5.1")
    ],
    targets: [
        // Clients
        .target(name: "AVAssetClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/AVAssetClient"),
        .target(name: "AVAudioPlayerClient", dependencies: [composableArchitecture], path: "Sources/Clients/AVAudioPlayerClient"),
        .target(name: "AVAudioRecorderClient", dependencies: [composableArchitecture], path: "Sources/Clients/AVAudioRecorderClient"),
        .target(name: "AVAudioSessionClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/AVAudioSessionClient"),
        .target(name: "AVCaptureDeviceClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/AVCaptureDeviceClient"),
        .target(name: "CoreDataClient", dependencies: [composableArchitecture, "Models"], path: "Sources/Clients/CoreDataClient"),
        .target(name: "FeedbackGeneratorClient", dependencies: [dependencies], path: "Sources/Clients/FeedbackGeneratorClient"),
        .target(name: "FileClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/FileClient"),
        .target(name: "LocalAuthenticationClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/LocalAuthenticationClient"),
        .target(name: "PDFKitClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/PDFKitClient"),
        .target(name: "StoreKitClient", dependencies: [dependencies], path: "Sources/Clients/StoreKitClient"),
        .target(name: "UIApplicationClient", dependencies: [dependencies], path: "Sources/Clients/UIApplicationClient"),
        .target(name: "UserDefaultsClient", dependencies: [dependencies, "Models"], path: "Sources/Clients/UserDefaultsClient"),
        // App
        .target(
            name: "AppFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
                "SplashFeature",
                "OnboardingFeature",
            ],
            path: "Sources/Features/ClipFeature"
        ),
        // Entries
        .target(
            name: "AddEntryFeature",
            dependencies: [
                composableArchitecture,
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
                "AVAssetClient"
            ],
            path: "Sources/Features/Entries/AddEntryFeature"
        ),
        .target(
            name: "AttachmentsFeature",
            dependencies: [
                composableArchitecture,
                "CoreDataClient",
                "FileClient",
                "Views",
                "Models",
                "Localizables",
                "AVAudioPlayerClient",
                "UIApplicationClient",
                "SwiftHelper"
            ],
            path: "Sources/Features/Entries/AttachmentsFeature"
        ),
        .target(
            name: "AudioPickerFeature",
            dependencies: [
                composableArchitecture
            ],
            path: "Sources/Features/Entries/AudioPickerFeature"
        ),
        .target(
            name: "AudioRecordFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
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
                composableArchitecture,
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
                composableArchitecture
            ],
            path: "Sources/Features/Entries/ImagePickerFeature"
        ),
        .target(
            name: "SearchFeature",
            dependencies: [
                composableArchitecture,
                "EntriesFeature",
                "CoreDataClient",
                "UIApplicationClient",
                "AVCaptureDeviceClient",
                "FileClient"
            ],
            path: "Sources/Features/Entries/SearchFeature"
        ),
        // Home
        .target(
            name: "HomeFeature",
            dependencies: [
                composableArchitecture,
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
                "PDFKitClient",
					 "TCAHelpers"
            ],
            path: "Sources/Features/HomeFeature"
        ),
        // LockScreen
        .target(
            name: "LockScreenFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
                "UserDefaultsClient",
                "Styles",
                "Views",
                "EntriesFeature",
                "FeedbackGeneratorClient",
					 "TCAHelpers"
            ],
            path: "Sources/Features/OnboardingFeature"
        ),
        // Root
        .target(
            name: "RootFeature",
            dependencies: [
                composableArchitecture,
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
                "PDFKitClient",
					 "TCAHelpers"
            ],
            path: "Sources/Features/RootFeature"
        ),
        // Settings
        .target(
            name: "AboutFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
                "UIApplicationClient",
                "Localizables",
                "Views"
            ],
            path: "Sources/Features/Settings/AgreementsFeature"
        ),
        .target(
            name: "AppearanceFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
                "AVCaptureDeviceClient",
                "UIApplicationClient",
                "FeedbackGeneratorClient",
                "Styles",
                "Localizables",
                "SwiftUIHelper"
            ],
            path: "Sources/Features/Settings/CameraFeature"
        ),
        .target(
            name: "ExportFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
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
                composableArchitecture,
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
                composableArchitecture,
                "LocalAuthenticationClient",
                "UserDefaultsClient",
                "Styles",
                "Views",
                "Localizables",
                "SwiftUIHelper",
					 "TCAHelpers"
            ],
            path: "Sources/Features/Settings/PasscodeFeature"
        ),
        .target(
            name: "PDFPreviewFeature",
            dependencies: [
                composableArchitecture,
                "PDFKitClient",
                "Views"
            ],
            path: "Sources/Features/Settings/PDFPreviewFeature"
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                composableArchitecture,
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
                composableArchitecture,
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
            path: "Sources/Helpers/SwiftHelper"
        ),
        .target(
            name: "SwiftUIHelper",
            path: "Sources/Helpers/SwiftUIHelper"
        ),
		  .target(
				name: "TCAHelpers",
				dependencies: [
					 composableArchitecture
				],
				path: "Sources/Helpers/TCAHelpers"
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
                snapshotTesting
            ],
            path: "Tests/Features/Settings/AboutFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "AgreementsFeatureTests",
            dependencies: [
                "AgreementsFeature",
                snapshotTesting
            ],
            path: "Tests/Features/Settings/AgreementsFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "AppearanceFeatureTests",
            dependencies: [
                "AppearanceFeature",
                "EntriesFeature",
                snapshotTesting
            ],
            path: "Tests/Features/Settings/AppearanceFeatureTests",
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "CameraFeatureTests",
            dependencies: [
                "CameraFeature",
                snapshotTesting
            ],
            path: "Tests/Features/Settings/CameraFeatureTests",
            exclude: ["__Snapshots__"]
        ),
		  .testTarget(
				name: "LanguageFeatureTests",
				dependencies: [
					 "LanguageFeature",
					 snapshotTesting
				],
				path: "Tests/Features/Settings/LanguageFeatureTests",
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
