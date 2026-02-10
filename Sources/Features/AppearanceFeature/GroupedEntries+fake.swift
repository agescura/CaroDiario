import Foundation
import Localizables
import Models

extension [GroupedEntries] {
  static var fakeGroupedEntries: Self {
    let date = Date(timeIntervalSince1970: 1629486993)
    return [
      GroupedEntries(
        date: date,
        isExpanded: false,
        entries: [
          EntryModel(
            id: UUID(1),
            createdAt: date,
            dayDate: date,
            imagesCount: 1,
            message: "Entries.FakeEntry.FirstMessage".localized,
            updatedAt: date
          ),
          EntryModel(
            id: UUID(2),
            createdAt: date,
            dayDate: date,
            imagesCount: 1,
            message: "Entries.FakeEntry.SecondMessage".localized,
            updatedAt: date
          ),
        ]
      )
    ]
  }
}
