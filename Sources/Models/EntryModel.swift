import Foundation
import SQLiteData

@Selection
public struct EntryModel: Codable, Identifiable, Equatable, Hashable, Sendable {
  public let id: Entry.ID
  public var createdAt: Date
  public var dayDate: Date
  public var imagesCount: Int
  public var message: String
  public var updatedAt: Date
  public var videosCount: Int
  
  public init(
    id: Entry.ID,
    createdAt: Date,
    dayDate: Date,
    imagesCount: Int,
    message: String,
    updatedAt: Date,
    videosCount: Int
  ) {
    self.id = id
    self.createdAt = createdAt
    self.dayDate = dayDate
    self.imagesCount = imagesCount
    self.updatedAt = updatedAt
    self.message = message
    self.videosCount = videosCount
  }
}
