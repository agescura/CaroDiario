import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import Localizables
import Styles
import Models
import SwiftUIHelper

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
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .requestAccessResponse(authorized):
					state.userSettings.authorizedVideoStatus = authorized ? .authorized : .denied
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .cameraButtonTapped:
							switch state.userSettings.authorizedVideoStatus {
								case .notDetermined:
									return .run { send in
										await send(.requestAccessResponse(avCaptureDeviceClient.requestAccess()))
									}
									
								default:
									break
							}
							return .none
							
						case .goToSettings:
							guard state.userSettings.authorizedVideoStatus != .notDetermined else { return .none }
							return .run { _ in await applicationClient.openSettings() }
							
						case .task:
							return .run { send in
								await send(.requestAccessResponse(avCaptureDeviceClient.requestAccess()))
							}
					}
			}
		}
	}
}
