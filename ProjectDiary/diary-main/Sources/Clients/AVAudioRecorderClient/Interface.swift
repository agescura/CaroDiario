import ComposableArchitecture
import Foundation
import Dependencies

public enum RecordPermission {
	case undetermined
	case denied
	case granted
}

extension DependencyValues {
	public var avAudioRecorderClient: AVAudioRecorderClient {
		get { self[AVAudioRecorderClient.self] }
		set { self[AVAudioRecorderClient.self] = newValue }
	}
}

public struct AVAudioRecorderClient {
	public var currentTime: @Sendable () async -> TimeInterval?
	public var recordPermission: () -> RecordPermission
	public var requestRecordPermission: @Sendable () async -> RecordPermission
	public var startRecording: @Sendable (URL) async throws -> Bool
	public var stopRecording: @Sendable () async -> Void
	
	public init(
		currentTime: @escaping @Sendable () async -> TimeInterval?,
		recordPermission: @escaping () -> RecordPermission,
		requestRecordPermission: @escaping @Sendable () async -> RecordPermission,
		startRecording: @escaping @Sendable (URL) async throws -> Bool,
		stopRecording: @escaping @Sendable () async -> Void
	) {
		self.currentTime = currentTime
		self.recordPermission = recordPermission
		self.requestRecordPermission = requestRecordPermission
		self.startRecording = startRecording
		self.stopRecording = stopRecording
	}
}
