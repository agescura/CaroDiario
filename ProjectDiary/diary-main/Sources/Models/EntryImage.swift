import Foundation

public struct EntryImage: EntryAttachment, Equatable, Identifiable, Hashable {
    public var url: URL
    public var id: UUID
    public var lastUpdated: Date
    public var thumbnail: URL
    
    public init(
        id: UUID,
        lastUpdated: Date,
        thumbnail: URL,
        url: URL
    ) {
        self.id = id
        self.lastUpdated = lastUpdated
        self.thumbnail = thumbnail
        self.url = url
    }
}

extension EntryImage {
    
    var urls: [URL] {
        [thumbnail, url]
    }
}
