//
//  OnBoardingPreviewApp.swift
//  OnBoardingPreview
//
//  Created by Albert Gil Escura on 2/8/21.
//

import SwiftUI
import ComposableArchitecture
import OnboardingFeature
import UserDefaultsClientLive

@main
struct OnBoardingPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeOnBoardingView(
                store: .init(
                    initialState: .init(),
                    reducer: welcomeOnBoardingReducer,
                    environment: .init(
                        userDefaultsClient: .live(userDefaults:)(),
                        feedbackGeneratorClient: .noop,
                        mainQueue: .main,
                        backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
                        date: Date.init,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
