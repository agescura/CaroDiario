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
                store: Store(
                    initialState: .init(featureState: .splash(.init())),
                    reducer: clipReducer
                )
            )
        }
    }
}
