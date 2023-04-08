import Foundation
import UIKit
import Models
import Dependencies

extension DependencyValues {
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}

public struct FileClient {
    public var path: (UUID) -> URL
    public var removeAttachments: ([URL]) async -> Void
    public var addImage: (UIImage, EntryImage) async -> EntryImage
    public var addVideo: (URL, UIImage, EntryVideo) async -> EntryVideo
    public var addAudio: (URL, EntryAudio) async -> EntryAudio
    
    public init(
        path: @escaping (UUID) -> URL,
        removeAttachments: @escaping ([URL]) async -> Void,
        addImage: @escaping (UIImage, EntryImage) async -> EntryImage,
        addVideo: @escaping (URL, UIImage, EntryVideo) async -> EntryVideo,
        addAudio: @escaping (URL, EntryAudio) async -> EntryAudio
    ) {
        self.path = path
        self.removeAttachments = removeAttachments
        self.addImage = addImage
        self.addVideo = addVideo
        self.addAudio = addAudio
    }
}
