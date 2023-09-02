import ComposableArchitecture
import SwiftUI
import AVAudioRecorderClient
import AVAudioPlayerClient
import UIApplicationClient
import FileClient
import Localizables
import Models

public struct AudioRecordFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var audioRecordPermission: RecordPermission = .undetermined
		public var isRecording: Bool = false
		public var audioPath: URL?
		public var audioRecordDuration: TimeInterval = 0
		public var hasAudioRecorded: Bool = false
		public var showRecordAlert: Bool = false
		var isPlaying: Bool = false
		var playerDuration: Double = 0
		var isPlayerDragging: Bool = false
		var isDragging = false
		var playerProgress: CGFloat = 0
		var playerProgressTime: Double = 0
		public var showDismissAlert: Bool = false
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case audioPlayerDidFinish(TaskResult<Bool>)
		case audioRecorderDidFinish(TaskResult<Bool>)
		case delegate(Delegate)
		case finalRecordingTime(TimeInterval)
		case onAppear
		
		case requestMicrophonePermissionButtonTapped
		case requestMicrophonePermissionResponse(RecordPermission)
		case goToSettings
		case recordButtonTapped
		case record
		case stopRecording
		case removeRecording
		case startRecorderTimer
		case addSecondRecorderTimer
		case recordAlertButtonTapped
		case playButtonTapped
		case playerProgressAddTimer
		case playerProgressResponse(Double)
		case dragOnChanged(CGPoint)
		case dragOnEnded(CGPoint)
		case playerGoBackward
		case playerGoForward
		case removeAudioRecord
		case addAudio
		case dismissAlertButtonTapped
		
		public enum Alert: Equatable {
			case newRecord
			case dismiss
		}
		
		public enum Delegate: Equatable {
			case dismiss
		}
	}
	
	@Dependency(\.avAudioRecorderClient) private var avAudioRecorderClient
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.uuid) private var uuid
	private enum CancelID {
		case timer
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.newRecord)):
					return .send(.record)
					
				case .alert(.presented(.dismiss)):
					return .none
					
				case .alert:
					return .none
					
				case .audioPlayerDidFinish(.success(true)):
					state.playerProgress = 0
					state.isPlaying = false
					state.playerProgressTime = 0
					return .cancel(id: CancelID.timer)
				case .audioPlayerDidFinish:
					return .cancel(id: CancelID.timer)
					
				case .audioRecorderDidFinish(.success(true)):
					state.isRecording = false
					return .cancel(id: CancelID.timer)

				case .audioRecorderDidFinish(.success(false)):
					print("FAILURE FAILED")
					return .cancel(id: CancelID.timer)
				case let .audioRecorderDidFinish(.failure(error)):
					print("FAILURE \(error.localizedDescription)")
					return .cancel(id: CancelID.timer)
					
				case .delegate:
					return .none
					
				case let .finalRecordingTime(duration):
					state.audioRecordDuration = duration
					state.playerDuration = duration
					return .none
					
				case .onAppear:
					state.audioRecordPermission = self.avAudioRecorderClient.recordPermission()
					return .none
					
				case .requestMicrophonePermissionButtonTapped:
					return .run { @MainActor send in
						await send(
							.requestMicrophonePermissionResponse(
								self.avAudioRecorderClient.requestRecordPermission()
							)
						)
					}
					
				case let .requestMicrophonePermissionResponse(audioRecordPermission):
					state.audioRecordPermission = audioRecordPermission
					return .none
					
				case .goToSettings:
					return .run { _ in await self.applicationClient.openSettings() }
					
				case .recordButtonTapped:
					if state.isRecording {
						return .send(.stopRecording)
					} else {
						if state.hasAudioRecorded {
							return .send(.recordAlertButtonTapped)
						} else {
							return .send(.record)
						}
					}
					
				case .record:
					let id = self.uuid()
					let url = self.fileClient.path(id).appendingPathExtension("caf")
					state.audioPath = url
					
					state.audioRecordDuration = 0
					state.hasAudioRecorded = false
					state.isRecording = true
					return .run { send in
						async let startRecording: Void = send(
							.audioRecorderDidFinish(
								TaskResult { try await self.avAudioRecorderClient.startRecording(url) }
							)
						)
						for await _ in self.mainQueue.timer(interval: .seconds(1)) {
							await send(.addSecondRecorderTimer)
						}
						await startRecording
					}
					.cancellable(id: CancelID.timer)
					
				case .stopRecording:
					state.isRecording = false
					state.hasAudioRecorded = true
					return .run { send in
						if let currentTime = await self.avAudioRecorderClient.currentTime() {
							await send(.finalRecordingTime(currentTime))
						}
						await self.avAudioRecorderClient.stopRecording()
					}
					
				case .removeRecording:
					state.hasAudioRecorded = false
					return .none
					
				case .startRecorderTimer:
					return .none
					
				case .addSecondRecorderTimer:
					state.audioRecordDuration += 1
					return .none
					
				case .recordAlertButtonTapped:
					state.alert = AlertState {
						TextState("AudioRecord.Alert".localized)
					} actions: {
						ButtonState.cancel(TextState("Cancel".localized))
						ButtonState.destructive(TextState("Continue".localized), action: .send(.newRecord))
					} message: {
						TextState("AudioRecord.Alert.Message".localized)
					}
					return .none
					
				case .playButtonTapped:
					if state.isPlaying {
						state.isPlaying = false
						state.playerProgressTime = 0
						state.playerProgress = 0
						state.playerProgressTime = 0
						return .merge(
							.run { _ in try await self.avAudioPlayerClient.stop() },
							.cancel(id: CancelID.timer)
						)
					}
					state.isPlaying = true

					guard let audioPath = state.audioPath else { return .none }
					return .run { send in
						async let startPlaying: Void = send(
							.audioPlayerDidFinish(
								TaskResult { try await self.avAudioPlayerClient.play(audioPath) }
							)
						)
						for await _ in self.mainQueue.timer(interval: .seconds(1)) {
							await send(.playerProgressAddTimer)
						}
						await startPlaying
					}
					.cancellable(id: CancelID.timer)
					
				case .playerProgressAddTimer:
					if state.isDragging { return .none }
					state.playerProgressTime += 1
					return .send(.playerProgressResponse(state.playerProgressTime), animation: .default)
					
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
					return .none
					
				case .playerGoBackward:
					var decrease = state.playerProgressTime - 15
					if decrease < 0 { decrease = 0 }
					state.playerProgressTime = decrease
					return .none
					
				case .playerGoForward:
					let increase = state.playerProgressTime + 15
					if increase < state.playerDuration {
						state.playerProgressTime = increase
						return .none
					}
					return .none
					
				case .removeAudioRecord:
					state.hasAudioRecorded = false
					state.audioRecordDuration = 0
					return .none
					
				case .dismissAlertButtonTapped:
					guard state.showDismissAlert else { return .send(.delegate(.dismiss)) }
					
					state.alert = AlertState {
						TextState("Title")
					} actions: {
						ButtonState.cancel(TextState("Cancel".localized))
						ButtonState.destructive(TextState("Si, descartar"), action: .send(.dismiss))
					} message: {
						TextState("Message")
					}
					return .none
					
				case .addAudio:
					return .none
			}
		}
		.ifLet(\.$alert, action: /Action.alert)
	}
}
