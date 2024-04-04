import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAudioRecorderClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		currentTime: XCTUnimplemented("\(Self.self).currentTime"),
		recordPermission: XCTUnimplemented("\(Self.self).recordPermission"),
		requestRecordPermission: XCTUnimplemented("\(Self.self).requestRecordPermission"),
		startRecording: XCTUnimplemented("\(Self.self).startRecording"),
		stopRecording: XCTUnimplemented("\(Self.self).stopRecording")
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
