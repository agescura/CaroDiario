import SwiftUI
import ComposableArchitecture
import ClipFeature
import UserDefaultsClient
import FeedbackGeneratorClient
import UIApplicationClient

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
                        date: Date.init,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
