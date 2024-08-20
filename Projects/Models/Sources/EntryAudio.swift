import Foundation

public struct EntryAudio: EntryAttachment, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var lastUpdated: Date
    public var url: URL
    
    public init(
        id: UUID,
        lastUpdated: Date,
        url: URL
    ) {
        self.id = id
        self.lastUpdated = lastUpdated
        self.url = url
    }
}

extension EntryAudio {
    
    var urls: [URL] {
        [url]
    }
}

extension EntryAudio {
	public static var mock: Self {
		Self(
			id: UUID(),
			lastUpdated: Date(),
			url: .empty
		)
	}
}
