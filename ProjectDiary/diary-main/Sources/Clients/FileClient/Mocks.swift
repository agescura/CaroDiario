import Foundation
import Dependencies
import XCTestDynamicOverlay

extension FileClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    path: XCTUnimplemented("\(Self.self).path"),
    removeAttachments: XCTUnimplemented("\(Self.self).removeAttachments"),
    addImage: XCTUnimplemented("\(Self.self).addImage"),
    addVideo: XCTUnimplemented("\(Self.self).addVideo"),
    addAudio: XCTUnimplemented("\(Self.self).addAudio")
  )
}

extension FileClient {
    public static let noop: FileClient = Self(
        path: { _ in URL(string: "www.apple.com")! },
        removeAttachments: { _ in },
        addImage: { _, entryImage in entryImage },
        addVideo: { _, _, entryVideo in entryVideo },
        addAudio: { _, entryAudio  in entryAudio }
    )
}
