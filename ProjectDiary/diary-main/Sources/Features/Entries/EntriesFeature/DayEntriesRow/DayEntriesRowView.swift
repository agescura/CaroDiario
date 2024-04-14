import SwiftUI
import ComposableArchitecture
import Localizables
import Styles
import Models

@Reducer
public struct DayEntriesRow {
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
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.dayEntries, action: \.dayEntry) {
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
			store: self.store.scope(state: \.dayEntries, action: \.dayEntry)
    )
    .padding(.horizontal)
  }
}

public var fakeEntries: IdentifiedArrayOf<DayEntriesRow.State> {
	@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
	
	let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
	let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
	let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
	let date = Date(timeIntervalSince1970: 1629486993)
	
  return [
    .init(dayEntry: .init(entry: [
      .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
      .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
		]), id: id3)
  ]
}
