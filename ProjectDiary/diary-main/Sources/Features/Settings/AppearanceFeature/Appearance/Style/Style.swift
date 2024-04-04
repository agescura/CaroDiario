import Foundation
import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Models

public struct Style: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
  }

  public enum Action: Equatable {
    case styleChanged(StyleType)
    case entries(id: UUID, action: DayEntriesRow.Action)
  }
  
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  
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
    case let .styleChanged(styleChanged):
      state.styleType = styleChanged
      state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
      return .run { _ in
        await self.feedbackGeneratorClient.selectionChanged()
      }
      
    case .entries:
      return .none
    }
  }
}
