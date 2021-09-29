//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 5/9/21.
//

import ComposableArchitecture
import AVKit
import AVAssetClient

extension AVAssetClient {
    static let live = Self(
        commonMetadata: { url in
            let asset = AVAsset(url: url)
            
            var commonMetadata = CommonMetadata()
            for i in asset.commonMetadata {
                if i.commonKey?.rawValue == "artwork" {
                    commonMetadata.artwork = i.value as? Data
                }
                
                if i.commonKey?.rawValue == "title" {
                    commonMetadata.title = i.value as? String
                }
            }
            
            return Effect(value: commonMetadata)
        }
    )
}
