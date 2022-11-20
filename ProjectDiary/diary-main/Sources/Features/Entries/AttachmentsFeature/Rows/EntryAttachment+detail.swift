//
//  EntryAttachment+detail.swift
//  
//
//  Created by Albert Gil Escura on 14/8/21.
//

import Foundation
import Models

extension EntryAttachment {
  
  public var detail: AttachmentState? {
    if let image = self as? EntryImage {
      return .image(.init(entryImage: image))
    }
    if let video = self as? EntryVideo {
      return .video(.init(entryVideo: video))
    }
    if let audio = self as? EntryAudio {
      return .audio(.init(entryAudio: audio))
    }
    return nil
  }
}

extension EntryAttachment {
  
  public var addDetail: AttachmentAdd.State? {
    if let image = self as? EntryImage {
      return .image(.init(entryImage: image))
    }
    if let video = self as? EntryVideo {
      return .video(.init(entryVideo: video))
    }
    if let audio = self as? EntryAudio {
      return .audio(.init(entryAudio: audio))
    }
    return nil
  }
}
