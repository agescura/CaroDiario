import UIKit
import Dependencies

extension DependencyValues {
  public var avAssetClient: AVAssetClient {
    get { self[AVAssetClient.self] }
    set { self[AVAssetClient.self] = newValue }
  }
}

public struct AVAssetClient {
    public var commonMetadata: (URL) throws -> CommonMetadata
    public var generateThumbnail: (URL) throws -> UIImage
    
    public init(
        commonMetadata: @escaping (URL) throws -> CommonMetadata,
        generateThumbnail: @escaping (URL) throws -> UIImage
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
