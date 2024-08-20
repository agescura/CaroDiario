import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AVAudioRecorderClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		currentTime: unimplemented("\(Self.self).currentTime", placeholder: TimeInterval()),
		recordPermission: unimplemented("\(Self.self).recordPermission", placeholder: .undetermined),
		requestRecordPermission: unimplemented("\(Self.self).requestRecordPermission", placeholder: .undetermined),
		startRecording: unimplemented("\(Self.self).startRecording"),
		stopRecording: unimplemented("\(Self.self).stopRecording")
	)
}

extension AVAudioRecorderClient {
	public static var noop = Self(
		currentTime: { 0 },
		recordPermission: { .undetermined },
		requestRecordPermission: { .undetermined },
		startRecording: { _ in true },
		stopRecording: {}
	)
}
