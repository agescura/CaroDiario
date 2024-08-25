import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import Localizables
import Styles
import Models
import SwiftUIHelper

@ViewAction(for: CameraFeature.self)
public struct CameraView: View {
	public let store: StoreOf<CameraFeature>
	
	public init(
		store: StoreOf<CameraFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Form {
			Section(
				footer:
					Group {
						if store.userSettings.authorizedVideoStatus != .denied {
							Text(store.userSettings.authorizedVideoStatus.description)
						} else {
							Text(store.userSettings.authorizedVideoStatus.description)
							+ Text(" ") +
							Text("Settings.GoToSettings".localized)
								.underline()
								.foregroundColor(.blue)
						}
					}
					.textStyle(.body)
					.onTapGesture {
						send(.goToSettings)
					}
			) {
				Group {
					HStack {
						Text(store.userSettings.authorizedVideoStatus.rawValue.localized)
						Spacer()
						if store.userSettings.authorizedVideoStatus == .notDetermined {
							Text(store.userSettings.authorizedVideoStatus.permission)
							Image(.chevronRight)
						}
					}
				}
				.textStyle(.body)
				.contentShape(Rectangle())
				.onTapGesture {
					send(.cameraButtonTapped)
				}
			}
		}
		.navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
		.task { await send(.task).finish() }
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

#Preview {
	CameraView(
		store: Store(
			initialState: CameraFeature.State(),
			reducer: { CameraFeature() }
		)
	)
}
