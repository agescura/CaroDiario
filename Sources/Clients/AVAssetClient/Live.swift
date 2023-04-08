import AVKit
import Models
import Combine
import Dependencies

extension AVAssetClient: DependencyKey {
  public static var liveValue: AVAssetClient = Self(
    commonMetadata: { url in
      let asset = AVAsset(url: url)
      
      var commonMetadata = CommonMetadata()
      for i in try await asset.load(.commonMetadata) {
        if i.commonKey?.rawValue == "artwork" {
          commonMetadata.artwork = try await i.load(.value) as? Data
        }
        
        if i.commonKey?.rawValue == "title" {
          commonMetadata.title = try await i.load(.value) as? String
        }
      }
      
      return commonMetadata
    },
    
    generateThumbnail: { url in
      throw AVAssetError.generatedThumbnailFailed
    }
  )
}

