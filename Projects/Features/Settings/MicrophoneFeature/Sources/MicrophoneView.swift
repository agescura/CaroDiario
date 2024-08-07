import ComposableArchitecture
import SwiftUI
import Localizables
import Styles
import Models
import SwiftUIHelper

public struct MicrophoneView: View {
	let store: StoreOf<MicrophoneFeature>
	
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
						if self.store.userSettings.audioRecordPermission != .denied {
							Text(self.store.userSettings.audioRecordPermission.description)
						} else {
							Text(self.store.userSettings.audioRecordPermission.description)
							+ Text(" ") +
							Text("Settings.GoToSettings".localized)
								.underline()
								.foregroundColor(.blue)
						}
					}
					.onTapGesture {
						self.store.send(.goToSettings)
					}
			) {
				HStack {
					Text(self.store.userSettings.audioRecordPermission.title.localized)
						.foregroundColor(.chambray)
						.adaptiveFont(.latoRegular, size: 10)
					Spacer()
					if self.store.userSettings.audioRecordPermission == .notDetermined {
						Text("Settings.GivePermission".localized)
							.foregroundColor(.adaptiveGray)
							.adaptiveFont(.latoRegular, size: 8)
						Image(.chevronRight)
							.foregroundColor(.adaptiveGray)
					}
				}
				.contentShape(Rectangle())
				.onTapGesture {
					self.store.send(.microphoneButtonTapped)
				}
			}
		}
		.navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
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
