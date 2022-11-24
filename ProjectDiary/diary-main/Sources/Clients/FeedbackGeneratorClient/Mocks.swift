import Foundation
import Dependencies
import XCTestDynamicOverlay

extension FeedbackGeneratorClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    prepare: XCTUnimplemented("\(Self.self).prepare"),
    selectionChanged: XCTUnimplemented("\(Self.self).selectionChanged")
  )
}

extension FeedbackGeneratorClient {
    public static let noop = Self(
        prepare: { () },
        selectionChanged: { () }
    )
}
