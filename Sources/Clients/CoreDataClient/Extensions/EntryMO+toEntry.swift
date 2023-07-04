//
//  EntryMO+toEntry.swift
//  
//
//  Created by Albert Gil Escura on 31/7/21.
//

import Models
import Foundation

extension EntryMO : Identifiable {}

extension EntryMO {
    public func toEntry() -> Entry? {
        var entryAttachments: [EntryAttachment] = []
        
        guard let attachments = self.attachments?.allObjects as? [AttachmentMO] else { return nil }
        for attachment in attachments {
            if let image = attachment as? ImageMO,
               let entryImage = image.toEntryImage() {
                entryAttachments.append(entryImage)
            } else if let video = attachment as? VideoMO,
                      let entryVideo = video.toEntryVideo() {
                entryAttachments.append(entryVideo)
            } else if let audio = attachment as? AudioMO,
                      let entryAudio = audio.toEntryAudio() {
                entryAttachments.append(entryAudio)
            }
        }
        
        guard let id = id, let lastUpdated = lastUpdated, let startDay = startDay else { return nil }
        guard let textId = text?.id, let textMessage = text?.message, let textLastUpdated = text?.lastUpdated else { return nil }
        
        return Entry(
            id: id,
            date: lastUpdated,
            startDay: startDay,
            text: EntryText(
                id: textId,
                message: textMessage,
                lastUpdated: textLastUpdated
            ),
            attachments: entryAttachments
        )
    }
}

extension ImageMO {
    func toEntryImage() -> EntryImage? {
        guard let id = id,
              let lastUpdated = lastUpdated,
              let thumbnail = thumbnail,
              let url = url else { return nil }
        
        return EntryImage(
            id: id,
            lastUpdated: lastUpdated,
            thumbnail: thumbnail,
            url: url
        )
    }
}

extension VideoMO {
    func toEntryVideo() -> EntryVideo? {
        guard let id = id,
              let lastUpdated = lastUpdated,
              let thumbnail = thumbnail,
              let url = url else { return nil }
        
        return EntryVideo(
            id: id,
            lastUpdated: lastUpdated,
            thumbnail: thumbnail,
            url: url
        )
    }
}

extension AudioMO {
    func toEntryAudio() -> EntryAudio? {
        guard let id = id,
              let lastUpdated = lastUpdated,
              let url = url else { return nil }
        
        return EntryAudio(
            id: id,
            lastUpdated: lastUpdated,
            url: url
        )
    }
}
