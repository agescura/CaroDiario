import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAssetClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    commonMetadata: XCTUnimplemented("\(Self.self).commonMetadata"),
    generateThumbnail: XCTUnimplemented("\(Self.self).generateThumbnail")
  )
}

extension AVAssetClient {
    public static let noop = Self(
        commonMetadata: { _ in .fireAndForget {} },
        generateThumbnail: { _ in .fireAndForget {} }
    )
}
