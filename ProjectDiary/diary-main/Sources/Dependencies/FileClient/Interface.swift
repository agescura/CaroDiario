//
//  Interface.swift
//  FileClient
//
//  Created by Albert Gil Escura on 3/7/21.
//

import Foundation
import ComposableArchitecture
import UIKit
import SharedModels

public struct FileClient {
    public var path: (UUID) -> URL
    public var removeAttachments: ([URL], AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never>
    public var addImage: (UIImage, EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<EntryImage, Never>
    public var loadImage: (EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<Data, Never>
    public var addVideo: (URL, EntryVideo, AnySchedulerOf<DispatchQueue>) -> Effect<EntryVideo, Never>
    public var addAudio: (URL, EntryAudio, AnySchedulerOf<DispatchQueue>) -> Effect<EntryAudio, Never>
    
    public init(
        path: @escaping (UUID) -> URL,
        removeAttachments: @escaping ([URL], AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never>,
        addImage: @escaping (UIImage, EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<EntryImage, Never>,
        loadImage: @escaping (EntryImage, AnySchedulerOf<DispatchQueue>) -> Effect<Data, Never>,
        addVideo: @escaping (URL, EntryVideo, AnySchedulerOf<DispatchQueue>) -> Effect<EntryVideo, Never>,
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
