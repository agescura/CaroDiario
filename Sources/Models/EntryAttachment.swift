//
//  Attachment.swift
//  
//
//  Created by Albert Gil Escura on 1/8/21.
//

import Foundation

public protocol EntryAttachment {
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
