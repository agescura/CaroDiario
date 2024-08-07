import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAudioPlayerClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		currentTime: XCTUnimplemented("\(Self.self).currentTime"),
		play: XCTUnimplemented("\(Self.self).play"),
		stop: XCTUnimplemented("\(Self.self).stop")
	)
}

extension AVAudioPlayerClient {
	public static var noop = Self(
		currentTime: { 0 },
		play: { _ in true },
		stop: { }
	)
}
