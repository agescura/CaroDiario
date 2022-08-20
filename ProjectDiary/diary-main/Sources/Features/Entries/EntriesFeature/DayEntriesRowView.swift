//
//  DayEntryRowView.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 1/7/21.
//

import SwiftUI
import ComposableArchitecture
import Localizables
import Styles

public struct DayEntriesRowState: Identifiable, Equatable {
    public var dayEntries: DayEntriesState
    public let id: UUID
    
    public init(
        dayEntry: DayEntriesState,
        id: UUID
    ) {
        self.dayEntries = dayEntry
        self.id = id
    }
}

public enum DayEntriesRowAction: Equatable {
    case dayEntry(DayEntriesAction)
}

public struct DayEntriesRowView: View {
    let store: Store<DayEntriesRowState, DayEntriesRowAction>
    
    public init(
        store: Store<DayEntriesRowState, DayEntriesRowAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        DayEntriesView(
            store: store.scope(
                state: \.dayEntries,
                action: DayEntriesRowAction.dayEntry
            )
        )
        .padding(.horizontal)
    }
}

private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
private let date = Date.init(timeIntervalSince1970: 1629486993)

public func fakeEntries(with style: StyleType, layout: LayoutType) -> IdentifiedArrayOf<DayEntriesRowState> {
    [
        .init(dayEntry: .init(entry: [
            .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
            .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
        ], style: style, layout: layout), id: id3)
    ]
}
