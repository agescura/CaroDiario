import AVCaptureDeviceClient
import ComposableArchitecture
import FeedbackGeneratorClient
import Models
import UIApplicationClient

public struct CameraFeature: ReducerProtocol {
	public init() {}
	
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
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .cameraButtonTapped:
					switch state.cameraStatus {
						case .notDetermined:
							return .run { @MainActor send in
								await self.feedbackGeneratorClient.selectionChanged()
								await send(.requestAccessResponse(self.avCaptureDeviceClient.requestAccess()))
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
}
