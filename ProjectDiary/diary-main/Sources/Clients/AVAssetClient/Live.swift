import ComposableArchitecture
import AVKit
import Models
import Combine
import Dependencies

extension AVAssetClient: DependencyKey {
  public static var liveValue: AVAssetClient = Self(
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
      
      return commonMetadata
    },
    
    generateThumbnail: { url in
      throw AVAssetError.generatedThumbnailFailed
    }
  )
}

