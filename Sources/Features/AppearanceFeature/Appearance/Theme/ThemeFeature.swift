import ApplicationClient
import ComposableArchitecture
import Foundation
import Models
//import EntriesFeature

@Reducer
public struct ThemeFeature {
  public init() {}
  @ObservableState
  public struct State: Equatable {
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case themeChanged(ThemeType)
  }
  
  @Dependency(\.applicationClient.setUserInterfaceStyle) var setUserInterfaceStyle
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .themeChanged(newTheme):
        state.$userSettings.appearance.themeType.withLock { $0 = newTheme }
        return .run { [setUserInterfaceStyle] _ in
          await setUserInterfaceStyle(newTheme.userInterfaceStyle)
        }
      }
    }
  }
}
