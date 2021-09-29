//
//  SettingsFeaturePreviewApp.swift
//  SettingsFeaturePreview
//
//  Created by Albert Gil Escura on 8/8/21.
//

import SwiftUI
import ComposableArchitecture
import SettingsFeature
import LocalAuthenticationClientLive
import UserDefaultsClientLive
import AVCaptureDeviceClientLive
import UIApplicationClientLive
import FeedbackGeneratorClientLive
import AVAudioSessionClientLive
import PDFKitClientLive
import StoreKitClientLive

@main
struct SettingsFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(
                store: .init(
                    initialState: .init(
                        styleType: .rectangle,
                        layoutType: .horizontal,
                        themeType: .dark,
                        iconType: .dark,
                        hasPasscode: true,
                        cameraStatus: .notDetermined,
                        optionTimeForAskPasscode: nil
                    ),
                    reducer: settingsReducer,
                    environment: .init(
                        coreDataClient: .noop,
                        fileClient: .noop,
                        userDefaultsClient: .live(userDefaults:)(),
                        localAuthenticationClient: .live,
                        applicationClient: .live,
                        avCaptureDeviceClient: .live,
                        feedbackGeneratorClient: .live,
                        avAudioSessionClient: .live,
                        storeKitClient: .live,
                        pdfKitClient: .live,
                        mainQueue: .main,
                        backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
                        mainRunLoop: .main,
                        setUserInterfaceStyle: { userInterfaceStyle in
                            .fireAndForget {
                                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = userInterfaceStyle
                            }
                        }
                    )
                )
            )
        }
    }
}
