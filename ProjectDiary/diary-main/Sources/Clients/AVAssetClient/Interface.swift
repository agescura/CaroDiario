//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 5/9/21.
//

import ComposableArchitecture
import UIKit

public struct AVAssetClient {
    public var commonMetadata: (URL) -> Effect<CommonMetadata, Never>
    public var generateThumbnail: (URL) -> Effect<UIImage, Error>
    
    public init(
        commonMetadata: @escaping (URL) -> Effect<AVAssetClient.CommonMetadata, Never>,
        generateThumbnail: @escaping (URL) -> Effect<UIImage, Error>
    ) {
        self.commonMetadata = commonMetadata
        self.generateThumbnail = generateThumbnail
    }
    
    public struct CommonMetadata: Equatable {
        public var artwork: Data?
        public var title: String?
        
        public init(
            artwork: Data? = nil,
            title: String? = nil
        ) {
            self.artwork = artwork
            self.title = title
        }
    }
}
