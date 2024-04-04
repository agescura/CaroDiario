import ComposableArchitecture
import SwiftUI
import Styles
import Views
import SwiftUIHelper
import Models

public struct AppearanceView: View {
  let store: StoreOf<Appearance>
  
  public init(
    store: StoreOf<Appearance>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section {
//          NavigationLink(
//            route: viewStore.route,
//            case: /Appearance.State.Route.style,
//            onNavigate: { viewStore.send(.navigateStyle($0)) },
//            destination: { styleState in
//              StyleView(
//                store: self.store.scope(
//                  state: { _ in styleState },
//                  action: Appearance.Action.style
//                )
//              )
//            },
//            label: {
//              StyleRowView(title: viewStore.styleType.rawValue.localized)
//            }
//          )
//          NavigationLink(
//            route: viewStore.route,
//            case: /Appearance.State.Route.layout,
//            onNavigate: { viewStore.send(.navigateLayout($0)) },
//            destination: { layoutState in
//              LayoutView(
//                store: self.store.scope(
//                  state: { _ in layoutState },
//                  action: Appearance.Action.layout
//                )
//              )
//            },
//            label: {
//              LayoutRowView(title: viewStore.layoutType.rawValue.localized)
//            }
//          )
//          NavigationLink(
//            route: viewStore.route,
//            case: /Appearance.State.Route.theme,
//            onNavigate: { viewStore.send(.navigateTheme($0)) },
//            destination: { themeState in
//              ThemeView(
//                store: self.store.scope(
//                  state: { _ in themeState },
//                  action: Appearance.Action.theme
//                )
//              )
//            },
//            label: {
//              ThemeRowView(
//                iconName: viewStore.themeType.icon,
//                title: viewStore.themeType.rawValue.localized
//              )
//            }
//          )
//          NavigationLink(
//            route: viewStore.route,
//            case: /Appearance.State.Route.iconApp,
//            onNavigate: { viewStore.send(.navigateIconApp($0)) },
//            destination: { iconAppState in
//              IconAppView(
//                store: self.store.scope(
//                  state: { _ in iconAppState },
//                  action: Appearance.Action.iconApp
//                )
//              )
//            },
//            label: {
//              IconAppRowView(title: viewStore.iconAppType.rawValue.localized)
//            }
//          )
        }
      }
    }
    .navigationBarTitle("Settings.Appearance".localized)
  }
}
