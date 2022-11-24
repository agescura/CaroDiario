import Foundation
import ComposableArchitecture
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
    public var removeAttachments: ([URL], AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never>
    public var addImage: (UIImage, EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<EntryImage, Never>
    public var loadImage: (EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<Data, Never>
    public var addVideo: (URL, UIImage, EntryVideo, AnySchedulerOf<DispatchQueue>) -> Effect<EntryVideo, Never>
    public var addAudio: (URL, EntryAudio, AnySchedulerOf<DispatchQueue>) -> Effect<EntryAudio, Never>
    
    public init(
        path: @escaping (UUID) -> URL,
        removeAttachments: @escaping ([URL], AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never>,
        addImage: @escaping (UIImage, EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<EntryImage, Never>,
        loadImage: @escaping (EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<Data, Never>,
        addVideo: @escaping (URL, UIImage, EntryVideo, AnySchedulerOf<DispatchQueue>) -> Effect<EntryVideo, Never>,
        addAudio: @escaping (URL, EntryAudio, AnySchedulerOf<DispatchQueue>) -> Effect<EntryAudio, Never>
    ) {
        self.path = path
        self.removeAttachments = removeAttachments
        self.addImage = addImage
        self.loadImage = loadImage
        self.addVideo = addVideo
        self.addAudio = addAudio
    }
}
