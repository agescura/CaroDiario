import Foundation
import SQLiteData

@Table
public struct Entry: Identifiable, Sendable, Codable {
  public var id: UUID
  public var createdAt: Date
  public var updatedAt: Date
  public var message: String
  //    public var attachments: [EntryAttachment]
  
  public init(
    id: UUID,
    createdAt: Date,
    updatedAt: Date,
    message: String
  ) {
    self.id = id
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.message = message
  }
}

extension Entry.TableColumns {
  public var dayDate: some QueryExpression<Date> {
    #sql("strftime('%Y-%m-%d 00:00:00', updatedAt)")
  }
}


extension Entry.Draft: Equatable, Sendable {}

extension Entry: Equatable {
  public static func == (lhs: Entry, rhs: Entry) -> Bool {
    lhs.id == rhs.id
  }
}

extension Entry: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Date {
  public var numberDay: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: self)
  }
  
  public var stringDay: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: self)
  }
  
  public var stringMonth: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter.string(from: self)
  }
  
  public var stringYear: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: self)
  }
  
  public var stringHour: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }
  
  public var stringLongDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm"
    return formatter.string(from: self)
  }
}

//extension Entry {
//    public var images: [EntryImage] {
//        attachments.filter { $0 is EntryImage }.compactMap { $0 as? EntryImage }
//    }
//    
//    public var videos: [EntryVideo] {
//        attachments.filter { $0 is EntryVideo }.compactMap { $0 as? EntryVideo }
//    }
//    
//    public var audios: [EntryAudio] {
//        attachments.filter { $0 is EntryAudio }.compactMap { $0 as? EntryAudio }
//    }
//}

extension Entry {
  public static var mock: Entry {
    Entry(
      id: UUID(0),
      createdAt: Date(timeIntervalSince1970: 1),
      updatedAt: Date(timeIntervalSince1970: 1),
      message: "Message"
    )
  }
}
