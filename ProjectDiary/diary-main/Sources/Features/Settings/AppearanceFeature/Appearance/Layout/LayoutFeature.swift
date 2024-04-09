import Foundation
import ComposableArchitecture
import FeedbackGeneratorClient
import Models
import EntriesFeature

@Reducer
public struct LayoutFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
    public var layoutType: LayoutType
    public var styleType: StyleType
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
    
    public init(
      layoutType: LayoutType,
      styleType: StyleType,
      entries: IdentifiedArrayOf<DayEntriesRow.State>
    ) {
      self.layoutType = layoutType
      self.styleType = styleType
      self.entries = entries
    }
  }

  public enum Action: Equatable {
    case layoutChanged(LayoutType)
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
      
    case let .layoutChanged(appearanceChanged):
      state.layoutType = appearanceChanged
      state.entries = fakeEntries
      
      return .run { _ in
        await self.feedbackGeneratorClient.selectionChanged()
      }
      
    case .entries:
      return .none
    }
  }
}
