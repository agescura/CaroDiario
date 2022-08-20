//
//  EntryVideo.swift
//  
//
//  Created by Albert Gil Escura on 31/7/21.
//

import Foundation

public struct EntryVideo: EntryAttachment, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var lastUpdated: Date
    public var thumbnail: URL
    public var url: URL
    
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

extension EntryVideo {
    
    var urls: [URL] {
        [thumbnail, url]
    }
}
