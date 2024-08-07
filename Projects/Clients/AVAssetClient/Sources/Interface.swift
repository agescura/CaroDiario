import UIKit
import Dependencies

extension DependencyValues {
  public var avAssetClient: AVAssetClient {
    get { self[AVAssetClient.self] }
    set { self[AVAssetClient.self] = newValue }
  }
}

public struct AVAssetClient {
  public var commonMetadata: @Sendable (URL) async throws -> CommonMetadata
  public var generateThumbnail: @Sendable (URL) async throws -> UIImage
  
  public init(
    commonMetadata: @escaping @Sendable (URL) async throws -> CommonMetadata,
    generateThumbnail: @escaping @Sendable (URL) async throws -> UIImage
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
