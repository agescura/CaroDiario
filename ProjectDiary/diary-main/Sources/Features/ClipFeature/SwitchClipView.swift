import ComposableArchitecture
import Dependencies
import SwiftUI
import SplashFeature
import OnboardingFeature
import UserDefaultsClient
import FeedbackGeneratorClient

public struct SwitchClip: ReducerProtocol {
    public init() {}
    
    public enum State: Equatable {
        case splash(SplashFeature.State)
        case onBoarding(Welcome.State)
    }
    
    public enum Action: Equatable {
        case splash(SplashFeature.Action)
        case onBoarding(Welcome.Action)
    }
    
    public var body: some ReducerProtocolOf<Self> {
        Scope(state: /State.splash, action: /Action.splash) {
            SplashFeature()
        }
        Scope(state: /State.onBoarding, action: /Action.onBoarding) {
            Welcome()
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
