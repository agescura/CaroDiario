import Foundation
import SQLiteData

@Selection
public struct GroupedEntries: Hashable, Equatable, Sendable {
  public let date: Date
  public let isExpanded: Bool

  @Column(as: [EntryModel].JSONRepresentation.self)
  public let entries: [EntryModel]
  
  public init(
    date: Date,
    isExpanded: Bool,
    entries: [EntryModel]
  ) {
    self.date = date
    self.isExpanded = isExpanded
    self.entries = entries
  }
}
