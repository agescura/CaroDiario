import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import ApplicationClient
import Localizables
import Models

@Reducer
public struct CameraFeature {
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
			case cameraButtonTapped
			case goToSettings
			case task
		}
	}
	
  @Dependency(\.applicationClient.openSettings) var openSettings
  @Dependency(\.avCaptureDeviceClient.requestAccess) var requestAccess
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .requestAccessResponse(authorized):
					state.$userSettings.authorizedVideoStatus.withLock { $0 = authorized ? .authorized : .denied }
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .cameraButtonTapped:
							switch state.userSettings.authorizedVideoStatus {
								case .notDetermined:
									return .run { [requestAccess] send in
										try await send(.requestAccessResponse(requestAccess()))
									}
									
								default:
									break
							}
							return .none
							
						case .goToSettings:
							guard state.userSettings.authorizedVideoStatus != .notDetermined else { return .none }
							return .run { [openSettings] _ in await openSettings() }
							
						case .task:
							return .run { [requestAccess] send in
								try await send(.requestAccessResponse(requestAccess()))
							}
					}
			}
		}
	}
}
