import Foundation
import ComposableArchitecture
import Models
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient
import AVAudioRecorderClient

public struct Microphone: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var microphoneStatus: RecordPermission
		
		public init(
			microphoneStatus: RecordPermission
		) {
			self.microphoneStatus = microphoneStatus
		}
	}
	
	public enum Action: Equatable {
		case microphoneButtonTapped
		
		case requestAccessResponse(RecordPermission)
		case goToSettings
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.avAudioRecorderClient) private var avAudioRecorderClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .microphoneButtonTapped:
					switch state.microphoneStatus {
						case .undetermined:
							return .run { @MainActor send in
								await self.feedbackGeneratorClient.selectionChanged()
								await send(.requestAccessResponse(self.avAudioRecorderClient.requestRecordPermission()))
							}
							
						default:
							break
					}
					return .none
					
				case let .requestAccessResponse(recordPermission):
					state.microphoneStatus = recordPermission
					return .none
					
				case .goToSettings:
					guard state.microphoneStatus != .undetermined else { return .none }
					return .run { _ in await self.applicationClient.openSettings() }
			}
		}
	}
}
