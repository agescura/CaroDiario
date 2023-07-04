import Foundation
import ComposableArchitecture
import Models
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct MicrophoneFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var microphoneStatus: AudioRecordPermission
		
		public var id: AudioRecordPermission { self.microphoneStatus }
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
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .microphoneButtonTapped:
					switch state.microphoneStatus {
						case .notDetermined:
							return .task { @MainActor in
								await self.feedbackGeneratorClient.selectionChanged()
								do {
									return .requestAccessResponse(try await self.avAudioSessionClient.requestRecordPermission())
								} catch {
									return .requestAccessResponse(false)
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
					return .fireAndForget { await self.applicationClient.openSettings() }
			}
		}
	}
}
