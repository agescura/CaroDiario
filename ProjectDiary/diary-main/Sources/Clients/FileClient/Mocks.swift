import Foundation
import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension FileClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    path: XCTUnimplemented("\(Self.self).path"),
    removeAttachments: XCTUnimplemented("\(Self.self).removeAttachments"),
    addImage: XCTUnimplemented("\(Self.self).addImage"),
    loadImage: XCTUnimplemented("\(Self.self).loadImage"),
    addVideo: XCTUnimplemented("\(Self.self).addVideo"),
    addAudio: XCTUnimplemented("\(Self.self).addAudio")
  )
}

extension FileClient {
    public static let noop: FileClient = Self(
        path: { _ in URL(string: "www.apple.com")! },
        removeAttachments: { _, _ in .fireAndForget {} },
        addImage: { image, entryImage, _ in
            return .fireAndForget {}
        },
        loadImage: { _, _ in .fireAndForget {} },
        addVideo: { _, _, _, _ in .fireAndForget {} },
        addAudio: { _, _ , _ in .fireAndForget {} }
    )
}
