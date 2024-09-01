import ComposableArchitecture
import SwiftUI
import Localizables
import Styles
import Models
import SwiftUIHelper

@ViewAction(for: MicrophoneFeature.self)
public struct MicrophoneView: View {
	public let store: StoreOf<MicrophoneFeature>
	
	public init(
		store: StoreOf<MicrophoneFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Form {
			Section(
				footer:
					Group {
						if store.userSettings.audioRecordPermission != .denied {
							Text(store.userSettings.audioRecordPermission.description)
						} else {
							Text(store.userSettings.audioRecordPermission.description)
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
				HStack {
					Text(store.userSettings.audioRecordPermission.title.localized)
					Spacer()
					if store.userSettings.audioRecordPermission == .notDetermined {
						Text("Settings.GivePermission".localized)
						Image(.chevronRight)
							.foregroundColor(.adaptiveGray)
					}
				}
				.textStyle(.body)
				.contentShape(Rectangle())
				.onTapGesture {
					send(.microphoneButtonTapped)
				}
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Settings.Camera.Privacy".localized)
					.textStyle(.body(.chambray))
			}
		}
	}
}


extension AudioRecordPermission {
	public var description: String {
		switch self {
			case .authorized:
				return "microphone.authorized.description".localized
			case .denied:
				return "microphone.denied.description".localized
			case .notDetermined:
				return "microphone.notDetermined.description".localized
		}
	}
}

extension AudioRecordPermission {
	public var title: String {
		switch self {
			case .authorized:
				return "microphone.authorized".localized
			case .denied:
				return "microphone.denied".localized
			case .notDetermined:
				return "microphone.notDetermined".localized
		}
	}
}
