import Foundation
import ComposableArchitecture
import Models
import Dependencies
import XCTestDynamicOverlay

extension CoreDataClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		subscriber: XCTUnimplemented("\(Self.self).subscriber"),
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
		subscriber: { .finished },
		createDraft: { _ in },
		publishEntry: { _ in },
		removeEntry: { _ in },
		fetchEntry: { _ in Entry.mock },
		fetchAll: { [] },
		updateMessage: { _, _ in },
		addAttachmentEntry: { _, _ in },
		removeAttachmentEntry: { _  in },
		searchEntries: { _ in [] },
		searchImageEntries: { [] },
		searchVideoEntries: { [] },
		searchAudioEntries: { [] }
	)
}
