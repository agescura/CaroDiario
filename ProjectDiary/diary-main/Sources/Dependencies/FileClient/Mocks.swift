//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 22/7/21.
//

import Foundation
import ComposableArchitecture

extension FileClient {
    public static let noop: FileClient = Self(
        path: { _ in URL(string: "www.apple.com")! },
        removeAttachments: { _, _ in .fireAndForget {} },
        addImage: { image, entryImage, _ in
            return .fireAndForget {}
        },
        loadImage: { _, _ in .fireAndForget {} },
        addVideo: { _, _, _ in .fireAndForget {} },
        addAudio: { _, _ , _ in .fireAndForget {} }
    )
}
