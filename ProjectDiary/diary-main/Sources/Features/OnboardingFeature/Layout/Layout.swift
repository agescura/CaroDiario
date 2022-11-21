import Foundation
import ComposableArchitecture
import EntriesFeature
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import UserDefaultsClient

public struct Layout: ReducerProtocol {
  public struct State: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
    public var skipAlert: AlertState<Action>?
    public var theme: Theme.State? = nil
    public var navigateTheme: Bool = false
    public var isAppClip = false
  }

  public enum Action: Equatable {
    case layoutChanged(LayoutType)
    case entries(id: UUID, action: DayEntriesRow.Action)
    case theme(Theme.Action)
    case navigateTheme(Bool)
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
  }
  
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.entries, action: /Action.entries) {
        DayEntriesRow()
      }
      .ifLet(\.theme, action: /Action.theme) {
        Theme()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .layoutChanged(layoutChanged):
      state.layoutType = layoutChanged
      state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
      return .fireAndForget {
        await self.feedbackGeneratorClient.selectionChanged()
      }
      
    case .entries:
      return .none
      
    case .theme:
      return .none
      
    case let .navigateTheme(value):
      state.navigateTheme = value
      let themeType = self.userDefaultsClient.themeType
      state.theme = value ? .init(
        themeType: themeType,
        entries: fakeEntries(with: self.userDefaultsClient.styleType,
                             layout: self.userDefaultsClient.layoutType),
        isAppClip: state.isAppClip) : nil
      return .fireAndForget {
        await self.setUserInterfaceStyle(themeType.userInterfaceStyle)
      }
      
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
      return self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
        .fireAndForget()
    }
  }
}

