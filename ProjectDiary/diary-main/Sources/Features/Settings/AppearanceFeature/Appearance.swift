import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

public struct Appearance: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var themeType: ThemeType
    public var iconAppType: IconAppType
    public var route: Route? {
      didSet {
        if case let .style(state) = self.route {
          self.styleType = state.styleType
        }
        if case let .layout(state) = self.route {
          self.layoutType = state.layoutType
        }
        if case let .theme(state) = self.route {
          self.themeType = state.themeType
        }
        if case let .iconApp(state) = self.route {
          self.iconAppType = state.iconAppType
        }
      }
    }
    
    public enum Route: Equatable {
      case style(Style.State)
      case layout(Layout.State)
      case iconApp(IconApp.State)
      case theme(Theme.State)
    }
    var style: Style.State? {
      get {
        guard case let .style(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .style(newValue)
      }
    }
    var layout: Layout.State? {
      get {
        guard case let .layout(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .layout(newValue)
      }
    }
    var iconApp: IconApp.State? {
      get {
        guard case let .iconApp(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .iconApp(newValue)
      }
    }
    var theme: Theme.State? {
      get {
        guard case let .theme(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .theme(newValue)
      }
    }
    
    public init(
      styleType: StyleType,
      layoutType: LayoutType,
      themeType: ThemeType,
      iconAppType: IconAppType,
      route: Route? = nil
    ) {
      self.styleType = styleType
      self.layoutType = layoutType
      self.themeType = themeType
      self.iconAppType = iconAppType
      self.route = route
    }
  }
  
  public enum Action: Equatable {
    case style(Style.Action)
    case navigateStyle(Bool)
    
    case layout(Layout.Action)
    case navigateLayout(Bool)
    
    case iconApp(IconApp.Action)
    case navigateIconApp(Bool)
    
    case theme(Theme.Action)
    case navigateTheme(Bool)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.style, action: /Action.style) {
        Style()
      }
      .ifLet(\.layout, action: /Action.layout) {
        Layout()
      }
      .ifLet(\.iconApp, action: /Action.iconApp) {
        IconApp()
      }
      .ifLet(\.theme, action: /Action.theme) {
        Theme()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case .theme:
      return .none
      
    case let .navigateTheme(value):
      state.route = value ? .theme(
        .init(
          themeType: state.themeType,
          entries: fakeEntries(with: state.styleType, layout: state.layoutType)
        )
      ) : nil
      return .none
      
    case .iconApp:
      return .none
      
    case let .navigateIconApp(value):
      state.route = value ? .iconApp(
        .init(iconAppType: state.iconAppType)
      ) : nil
      return .none
      
    case .style:
      return .none
      
    case let .navigateStyle(value):
      state.route = value ? .style(
        .init(
          styleType: state.styleType,
          layoutType: state.layoutType,
          entries: fakeEntries(with: state.styleType, layout: state.layoutType)
        )
      ) : nil
      return .none
      
    case .layout:
      return .none
      
    case let .navigateLayout(value):
      state.route = value ? .layout(
        .init(
          layoutType: state.layoutType,
          styleType: state.styleType,
          entries: fakeEntries(with: state.styleType, layout: state.layoutType)
        )
      ) : nil
      return .none
    }
  }
}
