import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient

public struct Welcome: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var privacy: Privacy.State?
    public var navigatePrivacy: Bool = false
    public var skipAlert: AlertState<Welcome.Action>?
    public var selectedPage = 0
    public var tabViewAnimated = false
    public var isAppClip = false
    
    public init(
      privacy: Privacy.State? = nil,
      navigatePrivacy: Bool = false,
      isAppClip: Bool = false
    ) {
      self.privacy = privacy
      self.navigatePrivacy = navigatePrivacy
      self.isAppClip = isAppClip
    }
  }
  
  public enum Action: Equatable {
    case privacy(Privacy.Action)
    case navigationPrivacy(Bool)
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
    case selectedPage(Int)
    case startTimer
    case nextPage
  }
  
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.continuousClock) private var clock
  private enum TimerID: Hashable {}
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.privacy, action: /Action.privacy) {
        Privacy()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
      
    case let .navigationPrivacy(value):
      state.privacy = value ? .init(isAppClip: state.isAppClip) : nil
      state.navigatePrivacy = value
      return .cancel(id: TimerID.self)
      
    case .privacy:
      return .none
      
    case .skipAlertButtonTapped:
      state.skipAlert = .init(
        title: .init("OnBoarding.Skip.Title".localized),
        message: .init("OnBoarding.Skip.Alert".localized),
        primaryButton: .cancel(.init("Cancel".localized), action: .send(.cancelSkipAlert)),
        secondaryButton: .destructive(.init("OnBoarding.Skip".localized), action: .send(.skipAlertAction))
      )
      return .none
      
    case .cancelSkipAlert:
      state.skipAlert = nil
      return .none
      
    case .skipAlertAction:
      state.skipAlert = nil
      return .merge(
        .fireAndForget { await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true) },
        .cancel(id: TimerID.self)
      )
      
    case .startTimer:
      return .run { send in
        while true {
          try await self.clock.sleep(for: .seconds(5))
          await send(.nextPage)
        }
      }
      .cancellable(id: TimerID.self)
      
    case let .selectedPage(value):
      state.selectedPage = value
      return .merge(
        .cancel(id: TimerID.self),
        .run { send in
          while true {
            try await self.clock.sleep(for: .seconds(5))
            await send(.nextPage)
          }
        }
          .cancellable(id: TimerID.self)
      )
      
    case .nextPage:
      state.tabViewAnimated = true
      if state.selectedPage == 2 {
        state.selectedPage = 0
      } else {
        state.selectedPage += 1
      }
      return .none
    }
  }
}
