import Dependencies
import XCTestDynamicOverlay
import UIKit

extension AVAssetClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		commonMetadata: unimplemented("\(Self.self).commonMetadata"),
		generateThumbnail: unimplemented("\(Self.self).generateThumbnail")
  )
}

extension AVAssetClient {
    public static let noop = Self(
      commonMetadata: { _ in .init() },
      generateThumbnail: { _ in UIImage() }
    )
}
