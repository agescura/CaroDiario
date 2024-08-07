import AVFoundation
import ComposableArchitecture
import Dependencies

extension DependencyValues {
	public var avAudioPlayerClient: AVAudioPlayerClient {
		get { self[AVAudioPlayerClient.self] }
		set { self[AVAudioPlayerClient.self] = newValue }
	}
}

public struct AVAudioPlayerClient {
	public var currentTime: @Sendable () async -> TimeInterval
	public var play: @Sendable (URL) async throws -> Bool
	public var stop: @Sendable () async throws -> Void
	
	public init(
		currentTime: @escaping @Sendable () async -> TimeInterval,
		play: @escaping @Sendable (URL) async throws -> Bool,
		stop: @escaping @Sendable () async throws -> Void
	) {
		self.currentTime = currentTime
		self.play = play
		self.stop = stop
	}
}
