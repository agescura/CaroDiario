import Foundation
import SQLiteData

@Table
public struct Asset: Identifiable, Sendable, Equatable {
  public let id: UUID
  public var pathUrl: String
  public let format: Format
  
  public init(
    id: UUID,
    pathUrl: String,
    format: Format
  ) {
    self.id = id
    self.pathUrl = pathUrl
    self.format = format
  }
}

public enum Format: Int, QueryBindable, Sendable {
  case image = 1
  case video
  case audio
}

extension Asset.Draft: Sendable {}

@Table
public struct EntryAsset: Sendable, Equatable, Identifiable {
  public let id: UUID
  public let assetID: Asset.ID
  public let entryID: Entry.ID
  
  public init(
    id: UUID,
    assetID: Asset.ID,
    entryID: Entry.ID
  ) {
    self.id = id
    self.assetID = assetID
    self.entryID = entryID
  }
}

public protocol EntryAttachment: Sendable {
    var id: UUID { get }
    var lastUpdated: Date { get }
}

extension EntryAttachment {
    
    var urls: [URL] {
        if let image = self as? EntryImage {
            return image.urls
        }
        if let video = self as? EntryVideo {
            return video.urls
        }
        if let audio = self as? EntryAudio {
            return audio.urls
        }
        fatalError()
    }
}


extension Array where Element == EntryAttachment {
    
    public var urls: [URL] {
        var urls: [URL] = []
        for element in self {
            urls.append(contentsOf: element.urls)
        }
        return urls
    }
}
