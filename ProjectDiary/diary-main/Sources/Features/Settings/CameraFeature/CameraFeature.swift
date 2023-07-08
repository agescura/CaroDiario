import AVCaptureDeviceClient
import ComposableArchitecture
import FeedbackGeneratorClient
import Models
import UIApplicationClient

public struct CameraFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var cameraStatus: AuthorizedVideoStatus
		
		public var id: AuthorizedVideoStatus { self.cameraStatus }
		
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
							return .task { @MainActor in
								await self.feedbackGeneratorClient.selectionChanged()
								return .requestAccessResponse(await self.avCaptureDeviceClient.requestAccess())
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
					return .fireAndForget { await self.applicationClient.openSettings() }
			}
		}
	}
}
