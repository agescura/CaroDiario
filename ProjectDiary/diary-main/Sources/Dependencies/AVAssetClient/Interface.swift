//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 5/9/21.
//

import ComposableArchitecture

public struct AVAssetClient {
    public var commonMetadata: (URL) -> Effect<CommonMetadata, Never>
    
    public init(
        commonMetadata: @escaping (URL) -> Effect<AVAssetClient.CommonMetadata, Never>
    ) {
        self.commonMetadata = commonMetadata
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
