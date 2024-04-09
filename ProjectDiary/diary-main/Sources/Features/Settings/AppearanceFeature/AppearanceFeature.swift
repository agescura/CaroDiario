import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct AppearanceFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
	
		public init() {}
	//    public enum Route: Equatable {
	//      case style(Style.State)
	//      case layout(Layout.State)
	//      case iconApp(IconApp.State)
	//      case theme(Theme.State)
	//    }
	//    var style: Style.State? {
	//      get {
	//        guard case let .style(state) = self.route else { return nil }
	//        return state
//      }
//      set {
//        guard let newValue = newValue else { return }
//        self.route = .style(newValue)
//      }
//    }
//    var layout: Layout.State? {
//      get {
//        guard case let .layout(state) = self.route else { return nil }
//        return state
//      }
//      set {
//        guard let newValue = newValue else { return }
//        self.route = .layout(newValue)
//      }
//    }
//    var iconApp: IconApp.State? {
//      get {
//        guard case let .iconApp(state) = self.route else { return nil }
//        return state
//      }
//      set {
//        guard let newValue = newValue else { return }
//        self.route = .iconApp(newValue)
//      }
//    }
//    var theme: Theme.State? {
//      get {
//        guard case let .theme(state) = self.route else { return nil }
//        return state
//      }
//      set {
//        guard let newValue = newValue else { return }
//        self.route = .theme(newValue)
//      }
//    }
  }
  
  public enum Action: Equatable {
//    case style(Style.Action)
//    case navigateStyle(Bool)
//    
//    case layout(Layout.Action)
//    case navigateLayout(Bool)
//    
//    case iconApp(IconApp.Action)
//    case navigateIconApp(Bool)
//    
//    case theme(Theme.Action)
//    case navigateTheme(Bool)
  }
  
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
  
//  private func core(
//    state: inout State,
//    action: Action
//  ) -> Effect<Action> {
//    switch action {
//    case .theme:
//      return .none
//      
//    case let .navigateTheme(value):
//      state.route = value ? .theme(
//        .init(
//          themeType: state.themeType,
//          entries: fakeEntries
//        )
//      ) : nil
//      return .none
//      
//    case .iconApp:
//      return .none
//      
//    case let .navigateIconApp(value):
//      state.route = value ? .iconApp(
//        .init(iconAppType: state.iconAppType)
//      ) : nil
//      return .none
//      
//    case .style:
//      return .none
//      
//    case let .navigateStyle(value):
//      state.route = value ? .style(
//        .init(
//          styleType: state.styleType,
//          layoutType: state.layoutType,
//          entries: fakeEntries
//        )
//      ) : nil
//      return .none
//      
//    case .layout:
//      return .none
//      
//    case let .navigateLayout(value):
//      state.route = value ? .layout(
//        .init(
//          layoutType: state.layoutType,
//          styleType: state.styleType,
//          entries: fakeEntries
//        )
//      ) : nil
//      return .none
//    }
//  }
}
