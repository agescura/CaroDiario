import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAudioPlayerClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		currentTime: unimplemented("\(Self.self).currentTime", placeholder: 0),
		play: unimplemented("\(Self.self).play"),
		stop: unimplemented("\(Self.self).stop")
	)
}

extension AVAudioPlayerClient {
	public static var noop = Self(
		currentTime: { 0 },
		play: { _ in true },
		stop: { }
	)
}
