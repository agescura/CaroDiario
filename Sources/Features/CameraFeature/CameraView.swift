import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import ApplicationClient
import Localizables
import Models
import DesignSystem

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
          HStack(spacing: .s8) {
						Text(store.userSettings.authorizedVideoStatus.rawValue.localized)
						Spacer()
						if store.userSettings.authorizedVideoStatus == .notDetermined {
							Text(store.userSettings.authorizedVideoStatus.permission)
              Image(systemName: .chevronRight)
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
		.task { await send(.task).finish() }
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Settings.Camera.Privacy".localized)
					.textStyle(.body(.chambray))
			}
		}
	}
}

extension AuthorizedVideoStatus {
	var description: String {
		switch self {
			case .notDetermined:
				"notDetermined.description".localized
			case .denied:
				"denied.description".localized
			case .authorized:
				"authorized.description".localized
			case .restricted:
				"restricted.description".localized
		}
	}
	
	var permission: String {
		switch self {
			case .notDetermined:
				"Settings.GivePermission".localized
			default:
				""
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
