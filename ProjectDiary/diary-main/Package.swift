// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "diary-main",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SharedStyles",
            type: .dynamic,
            targets: ["SharedStyles"]),
        .library(name: "SharedModels",
                type: .dynamic,
                targets: ["SharedModels"]),
        .library(name: "SharedViews",
                 targets: ["SharedViews"]),
        .library(name: "SharedLocalizables",
                 targets: ["SharedLocalizables"]),
        
        .library(name: "UserDefaultsClient",
                type: .dynamic,
                targets: ["UserDefaultsClient"]),
        .library(name: "UserDefaultsClientLive",
                 targets: ["UserDefaultsClientLive"]),
        
        .library(name: "CoreDataClient",
                type: .dynamic,
                targets: ["CoreDataClient"]),
        .library(name: "CoreDataClientLive",
                 targets: ["CoreDataClientLive"]),
        
        .library(name: "FileClient",
                type: .dynamic,
                targets: ["FileClient"]),
        .library(name: "FileClientLive",
                 targets: ["FileClientLive"]),
        
        .library(name: "LocalAuthenticationClient",
                type: .dynamic,
                targets: ["LocalAuthenticationClient"]),
        .library(name: "LocalAuthenticationClientLive",
                targets: ["LocalAuthenticationClientLive"]),
        
        .library(name: "UIApplicationClient",
                type: .dynamic,
                targets: ["UIApplicationClient"]),
        .library(name: "UIApplicationClientLive",
                 targets: ["UIApplicationClientLive"]),
        
        .library(name: "AVCaptureDeviceClient",
                type: .dynamic,
                targets: ["AVCaptureDeviceClient"]),
        .library(name: "AVCaptureDeviceClientLive",
                 targets: ["AVCaptureDeviceClientLive"]),
        
        .library(name: "AVAudioPlayerClient",
                type: .dynamic,
                targets: ["AVAudioPlayerClient"]),
        .library(name: "AVAudioPlayerClientLive",
                targets: ["AVAudioPlayerClientLive"]),
        
        .library(name: "AVAudioRecorderClient",
                type: .dynamic,
                targets: ["AVAudioRecorderClient"]),
        .library(name: "AVAudioRecorderClientLive",
                 targets: ["AVAudioRecorderClientLive"]),
        
        .library(name: "AVAudioSessionClient",
                type: .dynamic,
                targets: ["AVAudioSessionClient"]),
        .library(name: "AVAudioSessionClientLive",
                 targets: ["AVAudioSessionClientLive"]),
        
        .library(name: "AVAssetClient",
                type: .dynamic,
                targets: ["AVAssetClient"]),
        .library(name: "AVAssetClientLive",
                 targets: ["AVAssetClientLive"]),
        
        .library(name: "FeedbackGeneratorClient",
                type: .dynamic,
                targets: ["FeedbackGeneratorClient"]),
        .library(name: "FeedbackGeneratorClientLive",
                 targets: ["FeedbackGeneratorClientLive"]),
        
        .library(name: "StoreKitClient",
                type: .dynamic,
                targets: ["StoreKitClient"]),
        .library(name: "StoreKitClientLive",
                targets: ["StoreKitClientLive"]),
        
        .library(name: "PDFKitClient",
                type: .dynamic,
                targets: ["PDFKitClient"]),
        .library(name: "PDFKitClientLive",
                 targets: ["PDFKitClientLive"]),
        
        .library(name: "RootFeature", targets: ["RootFeature"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "SplashFeature", targets: ["SplashFeature"]),
        .library(name: "OnBoardingFeature", targets: ["OnBoardingFeature"]),
        .library(name: "LockScreenFeature", targets: ["LockScreenFeature"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        
        .library(name: "EntriesFeature", targets: ["EntriesFeature"]),
        .library(name: "EntryDetailFeature", targets: ["EntryDetailFeature"]),
        
        .library(name: "AddEntryFeature", targets: ["AddEntryFeature"]),
        .library(name: "ImagePickerFeature", targets: ["ImagePickerFeature"]),
        .library(name: "AudioPickerFeature", targets: ["AudioPickerFeature"]),
        .library(name: "AttachmentsFeature", targets: ["AttachmentsFeature"]),
        .library(name: "AudioRecordFeature", targets: ["AudioRecordFeature"]),
        
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "PasscodeFeature", targets: ["PasscodeFeature"]),
        .library(name: "PDFPreviewFeature", targets: ["PDFPreviewFeature"]),
        
        .library(name: "SearchFeature", targets: ["SearchFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.28.1")
    ],
    targets: [
        .target(
            name: "SharedStyles",
            dependencies: [],
            path: "Sources/Shared/SharedStyles",
            resources: [.process("Fonts")]
        ),
        .target(
            name: "SharedModels",
            dependencies: [],
            path: "Sources/Shared/SharedModels"
        ),
        .target(
            name: "SharedViews",
            dependencies: [
                "SharedStyles"
            ],
            path: "Sources/Shared/SharedViews"
        ),
        .target(
            name: "SharedLocalizables",
            dependencies: [],
            path: "Sources/Shared/SharedLocalizables",
            resources: [.process("Resources")]
        ),
        
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedStyles"
            ],
            path: "Sources/Dependencies/UserDefaultsClient"),
        .target(
            name: "UserDefaultsClientLive",
            dependencies: [
            "UserDefaultsClient",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ],
            path: "Sources/Dependencies/UserDefaultsClientLive"
        ),
        
        .target(
            name: "CoreDataClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "SharedModels")
            ],
            path: "Sources/Dependencies/CoreDataClient"
        ),
        .target(
            name: "CoreDataClientLive",
            dependencies: [
                "SharedModels",
                "CoreDataClient"
            ],
            path: "Sources/Dependencies/CoreDataClientLive"
        ),
        
        .target(
            name: "FileClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "SharedModels")
            ],
            path: "Sources/Dependencies/FileClient"
        ),
        .target(
            name: "FileClientLive",
            dependencies: [
                "SharedModels",
                "FileClient"
            ],
            path: "Sources/Dependencies/FileClientLive"
        ),
        
        .target(
            name: "LocalAuthenticationClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/LocalAuthenticationClient"
        ),
        .target(
            name: "LocalAuthenticationClientLive",
            dependencies: [
            "LocalAuthenticationClient"
        ],
            path: "Sources/Dependencies/LocalAuthenticationClientLive"),
        
        .target(
            name: "UIApplicationClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/UIApplicationClient"
        ),
        .target(
            name: "UIApplicationClientLive",
            dependencies: [
            "UIApplicationClient"
        ],
            path: "Sources/Dependencies/UIApplicationClientLive"
        ),
        
        .target(
            name: "AVCaptureDeviceClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/AVCaptureDeviceClient"
        ),
        .target(
            name: "AVCaptureDeviceClientLive",
            dependencies: [
            "AVCaptureDeviceClient"
        ],
            path: "Sources/Dependencies/AVCaptureDeviceClientLive"
        ),
        
        .target(
            name: "AVAudioPlayerClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/AVAudioPlayerClient"
        ),
        .target(
            name: "AVAudioPlayerClientLive",
            dependencies: [
            "AVAudioPlayerClient"
        ],
            path: "Sources/Dependencies/AVAudioPlayerClientLive"
        ),
        
        .target(
            name: "AVAudioRecorderClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/AVAudioRecorderClient"
        ),
        .target(
            name: "AVAudioRecorderClientLive",
            dependencies: [
            "AVAudioRecorderClient"
        ],
            path: "Sources/Dependencies/AVAudioRecorderClientLive"
        ),
        
        .target(
            name: "AVAudioSessionClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/AVAudioSessionClient"
        ),
        .target(
            name: "AVAudioSessionClientLive",
            dependencies: [
            "AVAudioSessionClient"
        ],
            path: "Sources/Dependencies/AVAudioSessionClientLive"
        ),
        
        .target(
            name: "AVAssetClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/AVAssetClient"
        ),
        .target(
            name: "AVAssetClientLive",
            dependencies: [
            "AVAssetClient"
        ],
            path: "Sources/Dependencies/AVAssetClientLive"
        ),
        
        .target(
            name: "FeedbackGeneratorClient",
            dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ],
            path: "Sources/Dependencies/FeedbackGeneratorClient"
        ),
        .target(
            name: "FeedbackGeneratorClientLive",
            dependencies: [
            "FeedbackGeneratorClient"
        ],
            path: "Sources/Dependencies/FeedbackGeneratorClientLive"
        ),
        
        .target(
            name: "StoreKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/Dependencies/StoreKitClient"
        ),
        .target(
            name: "StoreKitClientLive",
            dependencies: [
                "StoreKitClient"
            ],
            path: "Sources/Dependencies/StoreKitClientLive"
        ),
        
        .target(
            name: "PDFKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels"
            ],
            path: "Sources/Dependencies/PDFKitClient"
        ),
        .target(
            name: "PDFKitClientLive",
            dependencies: [
                "PDFKitClient"
            ],
            path: "Sources/Dependencies/PDFKitClientLive"
        ),
        
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
                "SharedStyles",
                "UIApplicationClient",
                "FeedbackGeneratorClient",
                "StoreKitClient",
                "PDFKitClient"
            ],
            path: "Sources/Features/RootFeature"
        ),
        
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SplashFeature",
                "OnBoardingFeature",
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
        
        .target(
            name: "SplashFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "SharedStyles"
            ],
            path: "Sources/Features/SplashFeature"
        ),
        
        .target(
            name: "OnBoardingFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "SharedStyles",
                "SharedViews",
                "EntriesFeature",
                "FeedbackGeneratorClient"
            ],
            path: "Sources/Features/OnBoardingFeature"
        ),
        
        .target(
            name: "LockScreenFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedStyles",
                "SharedViews",
                "UserDefaultsClient",
                "LocalAuthenticationClient",
                "SharedLocalizables"
            ],
            path: "Sources/Features/LockScreenFeature"
        ),
        
        .target(
            name: "HomeFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedStyles",
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
        
        .target(
            name: "EntriesFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient",
                "CoreDataClient",
                "EntryDetailFeature",
                "AddEntryFeature",
                "SharedLocalizables",
                "AVCaptureDeviceClient"
            ],
            path: "Sources/Features/EntriesFeature"
        ),
        
        .target(
            name: "EntryDetailFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "SharedStyles",
                "SharedViews",
                "SharedLocalizables",
                "AVCaptureDeviceClient",
                "AttachmentsFeature",
                "UIApplicationClient",
                "AddEntryFeature"
            ],
            path: "Sources/Features/EntryDetailFeature"
        ),
        
        .target(
            name: "AddEntryFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "ImagePickerFeature",
                "SharedViews",
                "SharedLocalizables",
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
            path: "Sources/Features/AddEntryFeature"
        ),
        
        .target(
            name: "ImagePickerFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Features/ImagePickerFeature"
        ),
        
        .target(
            name: "AudioPickerFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/Features/AudioPickerFeature"
        ),
        
        .target(
            name: "AttachmentsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CoreDataClient",
                "FileClient",
                "SharedViews",
                "SharedModels",
                "SharedLocalizables",
                "AVAudioPlayerClient",
                "UIApplicationClient"
            ],
            path: "Sources/Features/AttachmentsFeature"
        ),
        
        .target(
            name: "AudioRecordFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "FileClient",
                "AVAudioRecorderClient",
                "AVAudioSessionClient",
                "AVAudioPlayerClient",
                "SharedViews",
                "UIApplicationClient",
                "SharedLocalizables"
            ],
            path: "Sources/Features/AudioRecordFeature"
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
                "PDFPreviewFeature"
            ],
            path: "Sources/Features/SettingsFeature"
        ),
        
        .target(
            name: "PasscodeFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "LocalAuthenticationClient",
                "UserDefaultsClient",
                "SharedStyles",
                "SharedViews",
                "SharedLocalizables"
            ],
            path: "Sources/Features/PasscodeFeature"
        ),
        
        .target(
            name: "PDFPreviewFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PDFKitClient",
                "SharedViews"
            ],
            path: "Sources/Features/PDFPreviewFeature"
        ),
        
        .target(
            name: "SearchFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "EntriesFeature",
                "CoreDataClient",
                "UIApplicationClient",
                "AVCaptureDeviceClient",
                "FileClient"
            ],
            path: "Sources/Features/SearchFeature"
        ),
        
        .testTarget(
            name: "UserDefaultsClientLiveTests",
            dependencies: ["UserDefaultsClientLive"]
        ),
        .testTarget(
            name: "CoreDataClientLiveTests",
            dependencies: ["CoreDataClientLive"]
        ),
        .testTarget(
            name: "FileClientLiveTests",
            dependencies: ["FileClientLive"]
        ),
        
        .testTarget(
            name: "RootFeatureTests",
            dependencies: ["RootFeature"]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        ),
        .testTarget(
            name: "SplashFeatureTests",
            dependencies: ["SplashFeature"]
        ),
        .testTarget(
            name: "OnBoardingFeatureTests",
            dependencies: ["OnBoardingFeature"]
        ),
        .testTarget(
            name: "LockScreenFeatureTests",
            dependencies: ["LockScreenFeature"]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"]
        ),
        .testTarget(
            name: "EntriesFeatureTests",
            dependencies: ["EntriesFeature"]
        ),
        .testTarget(
            name: "AddEntryFeatureTests",
            dependencies: ["AddEntryFeature"]
        ),
        .testTarget(
            name: "AttachmentsFeatureTests",
            dependencies: ["AttachmentsFeature"]
        ),
        .testTarget(
            name: "AudioRecordFeatureTests",
            dependencies: ["AudioRecordFeature"]
        ),
        
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: ["SettingsFeature"]
        ),
        .testTarget(
            name: "PasscodeFeatureTests",
            dependencies: ["PasscodeFeature"]
        ),
        
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: ["SearchFeature"]
        )
    ]
)
