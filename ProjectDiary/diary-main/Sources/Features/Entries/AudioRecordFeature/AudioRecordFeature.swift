import ComposableArchitecture
import SwiftUI
import AVAudioRecorderClient
import AVAudioSessionClient
import AVAudioPlayerClient
import UIApplicationClient
import FileClient
import Localizables
import Models

public struct AudioRecordFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var audioRecordPermission: AudioRecordPermission
		public var isRecording: Bool = false
		public var audioPath: URL?
		public var audioRecordDuration: TimeInterval = .init()
		public var hasAudioRecorded: Bool = false
		public var showRecordAlert: Bool = false
		public var recordAlert: AlertState<Action>?
		var isPlaying: Bool = false
		var playerDuration: Double = 0
		var isPlayerDragging: Bool = false
		var isDragging = false
		var playerProgress: CGFloat = 0
		var playerProgressTime: Double = 0
		public var showDismissAlert: Bool = false
		public var dismissAlert: AlertState<Action>?
		
		
		public init(
			audioRecordPermission: AudioRecordPermission
		) {
			self.audioRecordPermission = audioRecordPermission
		}
	}
	
	public enum Action: Equatable {
		case onAppear
		case requestMicrophonePermissionButtonTapped
		case requestMicrophonePermissionResponse(Bool)
		case goToSettings
		case recorderPlayer(AVAudioRecorderClient.Action)
		case audioPlayer(AVAudioPlayerClient.Action)
		case recordButtonTapped
		case record
		case stopRecording
		case removeRecording
		case startRecorderTimer
		case resetRecorderTimer
		case addSecondRecorderTimer
		case recordAlertButtonTapped
		case recordCancelAlert
		case playButtonTapped
		case isPlayingResponse(Bool)
		case playerProgressAddTimer
		case playerProgressResponse(Double)
		case dragOnChanged(CGPoint)
		case dragOnEnded(CGPoint)
		case playerGoBackward
		case playerGoForward
		case removeAudioRecord
		case dismissAlertButtonTapped
		case dismissCancelAlert
		case dismiss
		case addAudio
	}
	
	@Dependency(\.avAudioRecorderClient) private var avAudioRecorderClient
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.uuid) private var uuid
	private struct RecorderManagerId: Hashable {}
	private struct RecorderTimerId: Hashable {}
	private struct PlayerManagerId: Hashable {}
	private struct PlayerTimerId: Hashable {}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .onAppear:
				return self.avAudioRecorderClient.create(id: RecorderManagerId())
					.map(Action.recorderPlayer)
				
			case .requestMicrophonePermissionButtonTapped:
				return .task { @MainActor in
					do {
						return .requestMicrophonePermissionResponse(try await self.avAudioSessionClient.requestRecordPermission())
					} catch {
						return .requestMicrophonePermissionResponse(false)
					}
				}
				
			case let .requestMicrophonePermissionResponse(response):
				state.audioRecordPermission = response ? .authorized : .denied
				return .none
				
			case .goToSettings:
				return .fireAndForget { await self.applicationClient.openSettings() }
				
			case .recorderPlayer(.didFinishRecording):
				state.isRecording = false
				return .none
				
			case .recorderPlayer:
				return .none
				
			case .audioPlayer(.didFinishPlaying):
				state.playerProgress = 0
				state.isPlaying = false
				state.playerProgressTime = 0
				return .cancel(id: PlayerTimerId())
				
			case let .audioPlayer(.duration(duration)):
				state.playerDuration = duration
				return .none
				
			case .audioPlayer:
				return .none
				
			case .recordButtonTapped:
				if state.isRecording {
					return Effect(value: .stopRecording)
				} else {
					if state.hasAudioRecorded {
						return Effect(value: .recordAlertButtonTapped)
					} else {
						return Effect(value: .record)
					}
				}
				
			case .record:
				let id = self.uuid()
				state.audioPath = self.fileClient.path(id).appendingPathExtension("caf")
				guard let audioPath = state.audioPath else { return .none }
				
				state.hasAudioRecorded = false
				state.isRecording = true
				return .merge(
					self.avAudioRecorderClient.record(id: RecorderManagerId(), url: audioPath)
						.fireAndForget(),
					Effect(value: .startRecorderTimer)
				)
				
			case .stopRecording:
				guard let audioPath = state.audioPath else { return .none }
				
				state.isRecording = false
				state.hasAudioRecorded = true
				return .merge(
					self.avAudioRecorderClient.stop(id: RecorderManagerId())
						.fireAndForget(),
					.cancel(id: RecorderTimerId()),
					self.avAudioPlayerClient.create(id: PlayerManagerId(), url: audioPath)
						.map(Action.audioPlayer)
				)
				
			case .removeRecording:
				state.hasAudioRecorded = false
				
				return .merge(
					self.avAudioRecorderClient.destroy(id: RecorderManagerId())
						.fireAndForget(),
					Effect(value: .resetRecorderTimer)
				)
				
			case .startRecorderTimer:
				state.audioRecordDuration = 0
				return Effect.timer(id: RecorderTimerId(), every: 1, on: self.mainQueue.animation())
					.map { _ in .addSecondRecorderTimer }
				
			case .resetRecorderTimer:
				state.audioRecordDuration = 0
				return .cancel(id: RecorderTimerId())
				
			case .addSecondRecorderTimer:
				state.audioRecordDuration += 1
				return .none
				
			case .recordAlertButtonTapped:
				state.recordAlert = .init(
					title: .init("AudioRecord.Alert".localized),
					message: .init("AudioRecord.Alert.Message".localized),
					primaryButton: .cancel(.init("Cancel".localized), action: .send(.recordCancelAlert)),
					secondaryButton: .destructive(.init("Continue".localized), action: .send(.record))
				)
				return .none
				
			case .recordCancelAlert:
				state.recordAlert = nil
				return .none
				
			case .playButtonTapped:
				return self.avAudioPlayerClient.isPlaying(id: PlayerManagerId())
					.map(Action.isPlayingResponse)
				
			case let .isPlayingResponse(isPlaying):
				if isPlaying {
					state.isPlaying = false
					return .merge(
						self.avAudioPlayerClient.pause(id: PlayerManagerId())
							.fireAndForget(),
						.cancel(id: PlayerTimerId())
					)
				} else {
					state.isPlaying = true
					return .merge(
						self.avAudioPlayerClient.play(id: PlayerManagerId())
							.fireAndForget(),
						Effect.timer(id: PlayerTimerId(), every: 0.1, on: self.mainQueue)
							.map { _ in .playerProgressAddTimer }
					)
				}
				
			case .playerProgressAddTimer:
				if state.isDragging { return .none }
				
				return self.avAudioPlayerClient.currentTime(id: PlayerManagerId())
					.map(Action.playerProgressResponse)
				
			case let .playerProgressResponse(progress):
				state.playerProgressTime = progress
				
				let screen = UIScreen.main.bounds.width - 30
				let value = progress / state.playerDuration
				state.playerProgress = screen * CGFloat(value)
				return .none
				
			case let .dragOnChanged(position):
				state.isDragging = true
				state.playerProgress = position.x
				return .none
				
			case let .dragOnEnded(position):
				state.isDragging = false
				let screen = UIScreen.main.bounds.width - 30
				let percentage = position.x / screen
				state.playerProgressTime = Double(percentage) * state.playerDuration
				return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
					.fireAndForget()
				
			case .playerGoBackward:
				var decrease = state.playerProgressTime - 15
				if decrease < 0 { decrease = 0 }
				return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: decrease)
					.fireAndForget()
				
			case .playerGoForward:
				let increase = state.playerProgressTime + 15
				if increase < state.playerDuration {
					state.playerProgressTime = increase
					return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
						.fireAndForget()
				}
				return .none
				
			case .removeAudioRecord:
				state.hasAudioRecorded = false
				state.audioRecordDuration = 0
				return .none
				
			case .dismissAlertButtonTapped:
				guard state.showDismissAlert else { return Effect(value: .dismiss) }
				
				state.dismissAlert = .init(
					title: .init("Title"),
					message: .init("Message"),
					primaryButton: .cancel(.init("Cancel".localized), action: .send(.dismissCancelAlert)),
					secondaryButton: .destructive(.init("Si, descartar."), action: .send(.dismiss))
				)
				return .none
				
			case .dismissCancelAlert:
				state.dismissAlert = nil
				return .none
				
			case .dismiss:
				return .merge(
					self.avAudioRecorderClient.destroy(id: RecorderManagerId())
						.fireAndForget(),
					self.avAudioPlayerClient.destroy(id: PlayerManagerId())
						.fireAndForget()
				)
				
			case .addAudio:
				return .none
		}
	}
}
