import Foundation
import ComposableArchitecture
import Models
import Dependencies
import XCTestDynamicOverlay

extension CoreDataClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		subscriber: unimplemented("\(Self.self).subscriber", placeholder: .finished),
		createDraft: unimplemented("\(Self.self).createDraft"),
		publishEntry: unimplemented("\(Self.self).publishEntry"),
		removeEntry: unimplemented("\(Self.self).removeEntry"),
		fetchEntry: unimplemented("\(Self.self).fetchEntry", placeholder: .mock),
		fetchAll: unimplemented("\(Self.self).fetchAll", placeholder: []),
		updateMessage: unimplemented("\(Self.self).updateMessage"),
		addAttachmentEntry: unimplemented("\(Self.self).addAttachmentEntry"),
		removeAttachmentEntry: unimplemented("\(Self.self).removeAttachmentEntry"),
		searchEntries: unimplemented("\(Self.self).searchEntries", placeholder: []),
		searchImageEntries: unimplemented("\(Self.self).searchImageEntries", placeholder: []),
		searchVideoEntries: unimplemented("\(Self.self).searchVideoEntries", placeholder: []),
		searchAudioEntries: unimplemented("\(Self.self).searchAudioEntries", placeholder: [])
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
