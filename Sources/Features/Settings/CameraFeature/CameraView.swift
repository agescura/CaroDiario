import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient
import Localizables
import Styles
import Models
import SwiftUIHelper

public struct CameraView: View {
	let store: StoreOf<CameraFeature>
	
	public init(
		store: StoreOf<CameraFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
			Form {
				Section(
					footer:
						Group {
							if viewStore.cameraStatus != .denied {
								Text(viewStore.cameraStatus.description)
							} else {
								Text(viewStore.cameraStatus.description)
								+ Text(" ") +
								Text("Settings.GoToSettings".localized)
									.underline()
									.foregroundColor(.blue)
							}
						}
						.onTapGesture { viewStore.send(.goToSettings) }
				) {
					HStack {
						Text(viewStore.cameraStatus.rawValue.localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 10)
						Spacer()
						if viewStore.cameraStatus == .notDetermined {
							Text(viewStore.cameraStatus.permission)
								.foregroundColor(.adaptiveGray)
								.adaptiveFont(.latoRegular, size: 12)
							Image(.chevronRight)
								.foregroundColor(.adaptiveGray)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture { viewStore.send(.cameraButtonTapped) }
				}
			}
			.navigationBarTitle(
				"Settings.Camera.Privacy".localized,
				displayMode: .inline
			)
		}
	}
}

extension AuthorizedVideoStatus {
	var description: String {
		switch self {
			case .notDetermined:
				return "notDetermined.description".localized
			case .denied:
				return "denied.description".localized
			case .authorized:
				return "authorized.description".localized
			case .restricted:
				return "restricted.description".localized
		}
	}
	
	var permission: String {
		switch self {
			case .notDetermined:
				return "Settings.GivePermission".localized
			default:
				return ""
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CameraView(
				store: Store(
					initialState: CameraFeature.State(
						cameraStatus: .notDetermined
					),
					reducer: CameraFeature()
				)
			)
		}
		.previewDisplayName("NotDetermined")
		
		NavigationView {
			CameraView(
				store: Store(
					initialState: CameraFeature.State(
						cameraStatus: .authorized
					),
					reducer: CameraFeature()
				)
			)
		}
		.previewDisplayName("Authorized")
		
		NavigationView {
			CameraView(
				store: Store(
					initialState: CameraFeature.State(
						cameraStatus: .denied
					),
					reducer: CameraFeature()
				)
			)
		}
		.previewDisplayName("Denied")
	}
}
