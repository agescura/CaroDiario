import SwiftUI
import ComposableArchitecture
import Models
import UserDefaultsClient
import Localizables
import SwiftUIHelper
import Styles

public struct LanguageView: View {
  let store: StoreOf<LanguageFeature>
  
  public init(
    store: StoreOf<LanguageFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      List {
        ForEach(Localizable.allCases) { language in
          HStack {
            Text(language.localizable.localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 12)
            Spacer()
            if viewStore.language == language {
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
