import ComposableArchitecture
import Localizables
import Models
import Styles
import SwiftUI
import SwiftUIHelper
import UserDefaultsClient

public struct LanguageView: View {
	let store: StoreOf<LanguageFeature>
	
	public init(
		store: StoreOf<LanguageFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.language
		) { viewStore in
			List {
				ForEach(Localizable.allCases) { language in
					HStack {
						Text(language.localizable.localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
						Spacer()
						if viewStore.state == language {
							Image(.checkmark)
								.foregroundColor(.adaptiveGray)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						viewStore.send(.updateLanguageTapped(language))
					}
				}
			}
			.navigationBarTitle("Settings.Language".localized)
		}
	}
}

struct LanguageView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			LanguageView(
				store: Store(
					initialState: LanguageFeature.State(
						language: .english
					),
					reducer: LanguageFeature()
				)
			)
		}
		.previewDisplayName("English")
		
		NavigationView {
			LanguageView(
				store: Store(
					initialState: LanguageFeature.State(
						language: .spanish
					),
					reducer: LanguageFeature()
				)
			)
		}
		.previewDisplayName("Spanish")
	}
}
