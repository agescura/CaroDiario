import SwiftUI
import ComposableArchitecture
import Styles
import PasscodeFeature
import Views
import Models
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature
import SwiftUIHelper

public struct SettingsView: View {
  let store: StoreOf<Settings>
  
  public init(
    store: StoreOf<Settings>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationView {
        VStack {
          Form {
            Section {
              Toggle(
                isOn: viewStore.binding(
                  get: \.showSplash,
                  send: Settings.Action.toggleShowSplash
                ),
                label: SplashRowView.init
              )
              .toggleStyle(SwitchToggleStyle(tint: .chambray))
              
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.appearance,
                onNavigate: { viewStore.send(.navigateAppearance($0)) },
                destination: { appearanceState in
                  AppearanceView(
                    store: self.store.scope(
                      state: { _ in appearanceState },
                      action: Settings.Action.appearance
                    )
                  )
                },
                label: AppearanceRowView.init
              )
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.language,
                onNavigate: { viewStore.send(.navigateLanguage($0)) },
                destination: { languageState in
                  LanguageView(
                    store: self.store.scope(
                      state: { _ in languageState },
                      action: Settings.Action.language
                    )
                  )
                },
                label: {
                  LanguageRowView(
                    title: "Settings.Language".localized(with: [viewStore.authenticationType.rawValue]),
                    status: viewStore.language.localizable.localized
                  )
                }
              )
            }
            
            Section {
              PasscodeRowView(
                title: "Settings.Code".localized(with: [viewStore.authenticationType.rawValue]),
                status: viewStore.hasPasscode ? "Settings.On".localized : "Settings.Off".localized
              )
              .contentShape(Rectangle())
              .onTapGesture {
                if viewStore.hasPasscode {
                  viewStore.send(.navigateMenu(true))
                } else {
                  viewStore.send(.navigateActivate(true))
                }
              }
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.camera,
                onNavigate: { viewStore.send(.navigateCamera($0)) },
                destination: { cameraState in
                  CameraView(
                    store: self.store.scope(
                      state: { _ in cameraState },
                      action: Settings.Action.camera
                    )
                  )
                },
                label: {
                  CameraRowView(title: viewStore.cameraStatus.rawValue.localized)
                }
              )
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.microphone,
                onNavigate: { viewStore.send(.navigateMicrophone($0)) },
                destination: { microphoneState in
                  MicrophoneView(
                    store: self.store.scope(
                      state: { _ in microphoneState },
                      action: Settings.Action.microphone
                    )
                  )
                },
                label: {
                  MicrophoneRowView(title: viewStore.microphoneStatus.title.localized)
                }
              )
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.export,
                onNavigate: { viewStore.send(.navigateExport($0)) },
                destination: { exportState in
                  ExportView(
                    store: self.store.scope(
                      state: { _ in exportState },
                      action: Settings.Action.export
                    )
                  )
                },
                label: ExportRowView.init
              )
            }
            
            Section {
              ReviewRowView()
                .contentShape(Rectangle())
                .onTapGesture {
                  viewStore.send(.reviewStoreKit)
                }
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.agreements,
                onNavigate: { viewStore.send(.navigateAgreements($0)) },
                destination: { agreementsState in
                  AgreementsView(
                    store: self.store.scope(
                      state: { _ in agreementsState },
                      action: Settings.Action.agreements
                    )
                  )
                },
                label: AgreementsRowView.init
              )
              NavigationLink(
                route: viewStore.route,
                case: /Settings.State.Route.about,
                onNavigate: { viewStore.send(.navigateAbout($0)) },
                destination: { aboutState in
                  AboutView(
                    store: self.store.scope(
                      state: { _ in aboutState },
                      action: Settings.Action.about
                    )
                  )
                },
                label: AboutRowView.init
              )
            }
          }
          
          VStack {
            NavigationLink(
              route: viewStore.route,
              case: /Settings.State.Route.activate,
              onNavigate: { viewStore.send(.navigateActivate($0)) },
              destination: { activateState in
                ActivateView(
                  store: self.store.scope(
                    state: { _ in activateState },
                    action: Settings.Action.activate
                  )
                )
              },
              label: EmptyView.init
            )
            NavigationLink(
              route: viewStore.route,
              case: /Settings.State.Route.menu,
              onNavigate: { viewStore.send(.navigateMenu($0)) },
              destination: { menuState in
                MenuPasscodeView(
                  store: self.store.scope(
                    state: { _ in menuState },
                    action: Settings.Action.menu
                  )
                )
              },
              label: EmptyView.init
            )
          }
          .frame(height: 0)
        }
        .navigationTitle("Settings.Title".localized)
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
