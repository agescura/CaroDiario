import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient
import Localizables
import Styles
import Models
import SwiftUIHelper

@Reducer
public struct CameraFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var cameraStatus: AuthorizedVideoStatus
		
		public init(
			cameraStatus: AuthorizedVideoStatus
		) {
			self.cameraStatus = cameraStatus
		}
	}
	
	public enum Action: Equatable {
		case cameraButtonTapped
		case requestAccessResponse(Bool)
		case goToSettings
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.feedbackGeneratorClient) var feedbackGeneratorClient
	@Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
		case .cameraButtonTapped:
			switch state.cameraStatus {
			case .notDetermined:
				return .run { send in
					await self.feedbackGeneratorClient.selectionChanged()
					await send(.requestAccessResponse(await self.avCaptureDeviceClient.requestAccess()))
				}
				
			default:
				break
			}
			return .none
			
		case let .requestAccessResponse(authorized):
			state.cameraStatus = authorized ? .authorized : .denied
			return .none
			
		case .goToSettings:
			guard state.cameraStatus != .notDetermined else { return .none }
			return .run { _ in await self.applicationClient.openSettings() }
		}
	}
}
