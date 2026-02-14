import ComposableArchitecture
import DesignSystem
import Localizables
import Models
import SwiftUI

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
        HStack(spacing: .s16) {
					Text(language.localizable.localized)
						.foregroundColor(.chambray)
						.adaptiveFont(.latoRegular, size: 12)
					Spacer()
					if self.store.userSettings.language == language {
            Image(systemName: .checkmark)
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

#Preview {
  LanguageView(
    store: Store(
      initialState: LanguageFeature.State(),
      reducer: { LanguageFeature() }
    )
  )
}
