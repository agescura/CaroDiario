import SwiftUI
import ComposableArchitecture
import Models
import UserDefaultsClient
import Models
import Localizables
import SwiftUIHelper
import Styles

@Reducer
public struct LanguageFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case updateLanguageTapped(Localizable)
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .updateLanguageTapped(language):
					state.userSettings.language = language
					return .none
			}
		}
	}
}

public struct LanguageView: View {
	let store: StoreOf<LanguageFeature>
	
	public init(
		store: StoreOf<LanguageFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		List {
			ForEach(Localizable.allCases) { language in
				HStack {
					Text(language.localizable.localized)
						.foregroundColor(.chambray)
						.adaptiveFont(.latoRegular, size: 12)
					Spacer()
					if self.store.userSettings.language == language {
						Image(.checkmark)
							.foregroundColor(.adaptiveGray)
					}
				}
				.contentShape(Rectangle())
				.onTapGesture {
					self.store.send(.updateLanguageTapped(language))
				}
			}
		}
		.navigationBarTitle("Settings.Language".localized)
	}
}
