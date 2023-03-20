import SwiftUI
import ComposableArchitecture
import Models
import UserDefaultsClient
import Models
import Localizables
import SwiftUIHelper
import Styles

public struct Language: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var language: Localizable
    
    public init(
      language: Localizable
    ) {
      self.language = language
    }
  }
  
  public enum Action: Equatable {
    case updateLanguageTapped(Localizable)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case let .updateLanguageTapped(language):
      state.language = language
      return .none
    }
  }
}

public struct LanguageView: View {
  let store: StoreOf<Language>
  
  public init(
    store: StoreOf<Language>
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
