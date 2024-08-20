import Foundation
import Models
import Dependencies
import SwiftHelper
import XCTestDynamicOverlay

extension FileClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
		path: unimplemented("\(Self.self).path", placeholder: .empty),
		removeAttachments: unimplemented("\(Self.self).removeAttachments"),
		addImage: unimplemented("\(Self.self).addImage", placeholder: .mock),
		addVideo: unimplemented("\(Self.self).addVideo", placeholder: .mock),
		addAudio: unimplemented("\(Self.self).addAudio", placeholder: .mock)
  )
}

extension FileClient {
    public static let noop: FileClient = Self(
        path: { _ in URL(string: "www.apple.com")! },
        removeAttachments: { _ in () },
        addImage: { _, _ in EntryImage(id: .init(), lastUpdated: .init(), thumbnail: URL(string: "wwww.google.es")!, url: URL(string: "wwww.google.es")!) },
        addVideo: { _, _, _ in EntryVideo(id: .init(), lastUpdated: .init(), thumbnail: URL(string: "wwww.google.es")!, url: URL(string: "wwww.google.es")!) },
        addAudio: { _, _ in EntryAudio(id: .init(), lastUpdated: .init(), url: URL(string: "wwww.google.es")!) }
    )
}
