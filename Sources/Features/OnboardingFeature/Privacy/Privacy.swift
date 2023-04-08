import Foundation
import ComposableArchitecture
import UserDefaultsClient
import EntriesFeature

public struct Privacy: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var style: Style.State? = nil
    public var navigateStyle: Bool = false
    public var skipAlert: AlertState<Privacy.Action>?
    public var isAppClip = false
    
    public init(
      style: Style.State? = nil,
      navigateStyle: Bool = false,
      isAppClip: Bool = false
    ) {
      self.style = style
      self.navigateStyle = navigateStyle
      self.isAppClip = isAppClip
    }
  }
  
  public enum Action: Equatable {
    case style(Style.Action)
    case navigationStyle(Bool)
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
  }
  
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.style, action: /Action.style) {
        Style()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case .style:
      return .none
      
    case let .navigationStyle(value):
      let styleType = self.userDefaultsClient.styleType
      let layoutType = self.userDefaultsClient.layoutType
      
      state.navigateStyle = value
      state.style = value ? .init(
        styleType: styleType,
        layoutType: layoutType,
        entries: fakeEntries(with: styleType,
                             layout: layoutType),
        isAppClip: state.isAppClip) : nil
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
      return .fireAndForget { await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true) }
    }
  }
}
