import ComposableArchitecture
import Localizables
import Models
import Styles
import SwiftUI
import SwiftUIHelper

public struct CameraView: View {
	private let store: StoreOf<CameraFeature>
	
	public init(
		store: StoreOf<CameraFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.cameraStatus
		) { viewStore in
			Form {
				Section(
					footer:
						Group {
							if viewStore.state != .denied {
								Text(viewStore.state.description)
							} else {
								Text(viewStore.state.description)
								+ Text(" ") +
								Text("Settings.GoToSettings".localized)
									.underline()
									.foregroundColor(.blue)
							}
						}
						.onTapGesture {
							viewStore.send(.goToSettings)
						}
				) {
					HStack {
						Text(viewStore.state.rawValue.localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 10)
						Spacer()
						if viewStore.state == .notDetermined {
							Text(viewStore.state.permission)
								.foregroundColor(.adaptiveGray)
								.adaptiveFont(.latoRegular, size: 12)
							Image(.chevronRight)
								.foregroundColor(.adaptiveGray)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						viewStore.send(.cameraButtonTapped)
					}
				}
			}
			.navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
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
