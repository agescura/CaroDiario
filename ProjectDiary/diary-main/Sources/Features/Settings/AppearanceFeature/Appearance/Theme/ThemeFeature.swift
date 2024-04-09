import Foundation
import ComposableArchitecture
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import UserDefaultsClient
import EntriesFeature

@Reducer
public struct ThemeFeature {
  public init() {}
  
  public struct State: Equatable {
    public var themeType: ThemeType = .system
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
  }

  public enum Action: Equatable {
    case themeChanged(ThemeType)
    case entries(id: UUID, action: DayEntriesRow.Action)
  }
  
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
  
  public var body: some ReducerOf<Self> {
    Reduce(self.core)
      .forEach(\.entries, action: /Action.entries) {
        DayEntriesRow()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case let .themeChanged(newTheme):
      state.themeType = newTheme
      return .run { _ in
        await self.setUserInterfaceStyle(newTheme.userInterfaceStyle)
        await self.feedbackGeneratorClient.selectionChanged()
      }
    case .entries:
      return .none
    }
  }
}
