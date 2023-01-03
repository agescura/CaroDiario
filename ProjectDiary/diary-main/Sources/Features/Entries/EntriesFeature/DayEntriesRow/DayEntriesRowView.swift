import SwiftUI
import ComposableArchitecture
import Localizables
import Styles
import Models

public struct DayEntriesRow: ReducerProtocol {
  public init() {}
  
  public struct State: Identifiable, Equatable {
    public var dayEntries: DayEntries.State
    public let id: UUID
    
    public init(
      dayEntry: DayEntries.State,
      id: UUID
    ) {
      self.dayEntries = dayEntry
      self.id = id
    }
  }

  public enum Action: Equatable {
    case dayEntry(DayEntries.Action)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Scope(state: \.dayEntries, action: /Action.dayEntry) {
      DayEntries()
    }
  }
}

public struct DayEntriesRowView: View {
  let store: StoreOf<DayEntriesRow>
  
  public init(
    store: StoreOf<DayEntriesRow>
  ) {
    self.store = store
  }
  
  public var body: some View {
    DayEntriesView(
      store: store.scope(
        state: \.dayEntries,
        action: DayEntriesRow.Action.dayEntry
      )
    )
    .padding(.horizontal)
  }
}

private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
private let date = Date(timeIntervalSince1970: 1629486993)

public func fakeEntries(with style: StyleType, layout: LayoutType) -> IdentifiedArrayOf<DayEntriesRow.State> {
  [
    .init(dayEntry: .init(entry: [
      .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
      .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
    ], style: style, layout: layout), id: id3)
  ]
}
