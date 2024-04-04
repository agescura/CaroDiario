import ComposableArchitecture
import Dependencies
import SwiftUI
import SplashFeature
import OnboardingFeature
import UserDefaultsClient
import FeedbackGeneratorClient

public struct SwitchClip: Reducer {
    public init() {}
    
    public enum State: Equatable {
        case splash(SplashFeature.State)
        case onBoarding(WelcomeFeature.State)
    }
    
    public enum Action: Equatable {
        case splash(SplashFeature.Action)
        case onBoarding(WelcomeFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: /State.splash, action: /Action.splash) {
            SplashFeature()
        }
        Scope(state: /State.onBoarding, action: /Action.onBoarding) {
            WelcomeFeature()
        }
    }
}

public struct SwitchClipView: View {
    let store: StoreOf<SwitchClip>
    
    public init(
        store: StoreOf<SwitchClip>
    ) {
        self.store = store
    }
    
    public var body: some View {
        SwitchStore(self.store) {
            CaseLet(
                state: /SwitchClip.State.splash,
                action: SwitchClip.Action.splash,
                then: SplashView.init(store:)
            )
            
            CaseLet(
                state: /SwitchClip.State.onBoarding,
                action: SwitchClip.Action.onBoarding,
                then: WelcomeView.init(store:)
            )
        }
    }
}
