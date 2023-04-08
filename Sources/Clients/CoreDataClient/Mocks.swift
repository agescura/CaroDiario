import Foundation
import ComposableArchitecture
import Models
import Dependencies
import XCTestDynamicOverlay

extension CoreDataClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    create: XCTUnimplemented("\(Self.self).create"),
    destroy: XCTUnimplemented("\(Self.self).destroy"),
    createDraft: XCTUnimplemented("\(Self.self).createDraft"),
    publishEntry: XCTUnimplemented("\(Self.self).publishEntry"),
    removeEntry: XCTUnimplemented("\(Self.self).removeEntry"),
    fetchEntry: XCTUnimplemented("\(Self.self).fetchEntry"),
    fetchAll: XCTUnimplemented("\(Self.self).fetchAll"),
    updateMessage: XCTUnimplemented("\(Self.self).updateMessage"),
    addAttachmentEntry: XCTUnimplemented("\(Self.self).addAttachmentEntry"),
    removeAttachmentEntry: XCTUnimplemented("\(Self.self).removeAttachmentEntry"),
    searchEntries: XCTUnimplemented("\(Self.self).searchEntries"),
    searchImageEntries: XCTUnimplemented("\(Self.self).searchImageEntries"),
    searchVideoEntries: XCTUnimplemented("\(Self.self).searchVideoEntries"),
    searchAudioEntries: XCTUnimplemented("\(Self.self).searchAudioEntries")
  )
}

extension CoreDataClient {
    public static let noop = Self(
        create: { _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        createDraft: { entry in
            return .fireAndForget {}
        },
        publishEntry: { _ in .fireAndForget {} },
        removeEntry: { _ in .fireAndForget {} },
        fetchEntry: { _ in .fireAndForget {} },
        fetchAll: { .fireAndForget {} },
        updateMessage: { _, _ in .fireAndForget {} },
        addAttachmentEntry: { _, _ in .fireAndForget {} },
        removeAttachmentEntry: { _  in .fireAndForget {} },
        searchEntries: { _ in .fireAndForget {} },
        searchImageEntries: { .fireAndForget {} },
        searchVideoEntries: { .fireAndForget {} },
        searchAudioEntries: { .fireAndForget {} }
    )
}
