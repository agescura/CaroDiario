import AVKit
import Models
import Dependencies

extension AVAssetClient: DependencyKey {
  public static var liveValue: AVAssetClient { .live }
}

extension AVAssetClient {
    public static let live = Self(
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
            do {
                let asset = AVURLAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                             actualTime: nil)

                return UIImage(cgImage: cgImage)
            } catch {
                throw AVAssetError.generatedThumbnailFailed
            }
        }
    )
}
