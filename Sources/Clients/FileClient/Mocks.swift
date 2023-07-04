import Foundation
import Models
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
        removeAttachments: { _ in () },
        addImage: { _, _ in EntryImage(id: UUID(), lastUpdated: Date(), thumbnail: URL(string: "wwww.google.es")!, url: URL(string: "wwww.google.es")!) },
        addVideo: { _, _, _ in EntryVideo(id: UUID(), lastUpdated: Date(), thumbnail: URL(string: "wwww.google.es")!, url: URL(string: "wwww.google.es")!) },
        addAudio: { _, _ in EntryAudio(id: UUID(), lastUpdated: Date(), url: URL(string: "wwww.google.es")!) }
    )
}
