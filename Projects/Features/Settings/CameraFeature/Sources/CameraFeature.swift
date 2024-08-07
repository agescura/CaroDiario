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
	
	public enum Action: Equatable {
		case cameraButtonTapped
		case goToSettings
		case requestAccessResponse(Bool)
		case task
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .cameraButtonTapped:
					switch state.userSettings.authorizedVideoStatus {
						case .notDetermined:
							return .run { send in
								await send(.requestAccessResponse(self.avCaptureDeviceClient.requestAccess()))
							}
							
						default:
							break
					}
					return .none
					
				case .goToSettings:
					guard state.userSettings.authorizedVideoStatus != .notDetermined else { return .none }
					return .run { _ in await self.applicationClient.openSettings() }
					
				case let .requestAccessResponse(authorized):
					state.userSettings.authorizedVideoStatus = authorized ? .authorized : .denied
					return .none
					
				case .task:
					return .run { send in
						await send(.requestAccessResponse(self.avCaptureDeviceClient.requestAccess()))
					}
			}
		}
	}
}
