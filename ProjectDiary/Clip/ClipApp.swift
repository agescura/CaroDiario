//
//  ClipApp.swift
//  Clip
//
//  Created by Albert Gil Escura on 8/10/21.
//

import SwiftUI
import ComposableArchitecture
import ClipFeature
import UserDefaultsClientLive
import FeedbackGeneratorClientLive
import UIApplicationClientLive

@main
struct ClipApp: App {
    var body: some Scene {
        WindowGroup {
            ClipView(
                store: .init(
                    initialState: .init(featureState: .splash(.init())),
                    reducer: clipReducer,
                    environment: .init(
                        userDefaultsClient: .live(userDefaults:)(),
                        applicationClient: .live,
                        feedbackGeneratorClient: .live,
                        mainQueue: .main,
                        backgroundQueue: .main,
                        mainRunLoop: .main,
                        uuid: UUID.init,
                        setUserInterfaceStyle: { userInterfaceStyle in
                            .fireAndForget {
                                UIApplication.shared.connectedScenes
                                    .filter { $0.activationState == .foregroundActive }
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows.first?.overrideUserInterfaceStyle = userInterfaceStyle
                            }
                        }
                    )
                )
            )
        }
    }
}
