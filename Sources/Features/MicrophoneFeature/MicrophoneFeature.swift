import AVAudioSessionClient
import ComposableArchitecture
import Foundation
import Models
import ApplicationClient

@Reducer
public struct MicrophoneFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    public init() {}
  }
  
  public enum Action: ViewAction, Equatable {
		case requestAccessResponse(Bool)
		case view(View)
		
		@CasePathable
		public enum View: Equatable {
			case goToSettings
			case microphoneButtonTapped
			case task
		}
  }
  
  @Dependency(\.applicationClient.openSettings) private var openSettings
  @Dependency(\.avAudioSessionClient.requestRecordPermission) private var requestRecordPermission

	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .requestAccessResponse(authorized):
					state.$userSettings.audioRecordPermission.withLock { $0 = authorized ? .authorized : .denied }
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .goToSettings:
							guard state.userSettings.audioRecordPermission != .notDetermined else { return .none }
							return .run { [openSettings] _ in await openSettings() }
							
						case .microphoneButtonTapped:
							switch state.userSettings.audioRecordPermission {
								case .notDetermined:
									return .run { [requestRecordPermission] send in
										try await send(.requestAccessResponse(requestRecordPermission()))
									} catch: { _, send in
										await send(.requestAccessResponse(false))
								}
									
								default:
									break
							}
							return .none
							
						case .task:
							return .run { [requestRecordPermission] send in
								try await send(.requestAccessResponse(requestRecordPermission()))
							} catch: { _, send in
								await send(.requestAccessResponse(false))
							}
					}
			}
		}
	}
}
