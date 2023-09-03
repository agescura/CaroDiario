import Foundation
import ComposableArchitecture
import Models
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct Microphone: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var microphoneStatus: AudioRecordPermission
		
		public init(
			microphoneStatus: AudioRecordPermission
		) {
			self.microphoneStatus = microphoneStatus
		}
	}
	
	public enum Action: Equatable {
		case microphoneButtonTapped
		
		case requestAccessResponse(Bool)
		case goToSettings
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .microphoneButtonTapped:
					switch state.microphoneStatus {
						case .notDetermined:
							return .run { @MainActor send in
								await self.feedbackGeneratorClient.selectionChanged()
								do {
									try await send(.requestAccessResponse(self.avAudioSessionClient.requestRecordPermission()))
								} catch {
									send(.requestAccessResponse(false))
								}
							}
							
						default:
							break
					}
					return .none
					
				case let .requestAccessResponse(authorized):
					state.microphoneStatus = authorized ? .authorized : .denied
					return .none
					
				case .goToSettings:
					guard state.microphoneStatus != .notDetermined else { return .none }
					return .run { _ in await self.applicationClient.openSettings() }
			}
		}
	}
}
