import Foundation
import ComposableArchitecture
import Models
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient

@Reducer
public struct MicrophoneFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    public init() {}
  }
  
  public enum Action: Equatable {
		case goToSettings
    case microphoneButtonTapped
    case requestAccessResponse(Bool)
		case task
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.avAudioSessionClient) private var avAudioSessionClient

	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .goToSettings:
					guard state.userSettings.audioRecordPermission != .notDetermined else { return .none }
					return .run { _ in await self.applicationClient.openSettings() }
					
				case .microphoneButtonTapped:
					switch state.userSettings.audioRecordPermission {
						case .notDetermined:
							return .run { send in
								try await send(.requestAccessResponse(self.avAudioSessionClient.requestRecordPermission()))
							} catch: { _, send in
								await send(.requestAccessResponse(false))
						}
							
						default:
							break
					}
					return .none
					
				case let .requestAccessResponse(authorized):
					state.userSettings.audioRecordPermission = authorized ? .authorized : .denied
					return .none
					
				case .task:
					return .run { send in
						try await send(.requestAccessResponse(self.avAudioSessionClient.requestRecordPermission()))
					} catch: { _, send in
						await send(.requestAccessResponse(false))
					}
			}
		}
	}
}
