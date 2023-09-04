import Foundation
import ComposableArchitecture
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import AVAudioRecorderClient

public struct Microphone: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var recordPermission: RecordPermission
		
		public init(
			recordPermission: RecordPermission
		) {
			self.recordPermission = recordPermission
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
					switch state.recordPermission {
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
					state.recordPermission = recordPermission
					return .none
					
				case .goToSettings:
					guard state.recordPermission != .undetermined else { return .none }
					return .run { _ in await self.applicationClient.openSettings() }
			}
		}
	}
}
