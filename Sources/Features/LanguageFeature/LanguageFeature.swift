import ComposableArchitecture
import Models

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
          state.$userSettings.language.withLock { $0 = language }
          return .none
      }
    }
  }
}
