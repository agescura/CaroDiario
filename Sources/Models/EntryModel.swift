import Foundation
import SQLiteData

@Selection
public struct EntryModel: Codable, Identifiable, Equatable, Hashable, Sendable {
  public let id: Entry.ID
  public var createdAt: Date
  public var dayDate: Date
  public var message: String
  public var updatedAt: Date
  
  public init(
    id: Entry.ID,
    createdAt: Date,
    dayDate: Date,
    message: String,
    updatedAt: Date
  ) {
    self.id = id
    self.createdAt = createdAt
    self.dayDate = dayDate
    self.updatedAt = updatedAt
    self.message = message
  }
}
