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
  let store: Store<SettingsState, SettingsAction>
  
  public init(
    store: Store<SettingsState, SettingsAction>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        VStack {
          Form {
            Section {
              Toggle(
                isOn: viewStore.binding(
                  get: \.showSplash,
                  send: SettingsAction.toggleShowSplash
                ),
                label: SplashRowView.init
              )
              .toggleStyle(SwitchToggleStyle(tint: .chambray))
              
              NavigationLink(
                route: viewStore.route,
                case: /SettingsState.Route.appearance,
                onNavigate: { viewStore.send(.navigateAppearance($0)) },
                destination: { appearanceState in
                  AppearanceView(
                    store: self.store.scope(
                      state: { _ in appearanceState },
                      action: SettingsAction.appearance
                    )
                  )
                },
                label: AppearanceRowView.init
              )
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /SettingsState.Route.language,
                onNavigate: { viewStore.send(.navigateLanguage($0)) },
                destination: { languageState in
                  LanguageView(
                    store: self.store.scope(
                      state: { _ in languageState },
                      action: SettingsAction.language
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
                  viewStore.send(.navigateMenuPasscode(true))
                } else {
                  viewStore.send(.navigateActivatePasscode(true))
                }
              }
            }
            
            Section {
              NavigationLink(
                route: viewStore.route,
                case: /SettingsState.Route.camera,
                onNavigate: { viewStore.send(.navigateCamera($0)) },
                destination: { cameraState in
                  CameraView(
                    store: self.store.scope(
                      state: { _ in cameraState },
                      action: SettingsAction.camera
                    )
                  )
                },
                label: {
                  CameraRowView(title: viewStore.cameraStatus.rawValue.localized)
                }
              )
              NavigationLink(
                route: viewStore.route,
                case: /SettingsState.Route.microphone,
                onNavigate: { viewStore.send(.navigateMicrophone($0)) },
                destination: { microphoneState in
                  MicrophoneView(
                    store: self.store.scope(
                      state: { _ in microphoneState },
                      action: SettingsAction.microphoneAction
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
                case: /SettingsState.Route.export,
                onNavigate: { viewStore.send(.navigateExport($0)) },
                destination: { exportState in
                  ExportView(
                    store: self.store.scope(
                      state: { _ in exportState },
                      action: SettingsAction.export
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
                case: /SettingsState.Route.agreements,
                onNavigate: { viewStore.send(.navigateAgreements($0)) },
                destination: { agreementsState in
                  AgreementsView(
                    store: self.store.scope(
                      state: { _ in agreementsState },
                      action: SettingsAction.agreements
                    )
                  )
                },
                label: AgreementsRowView.init
              )
              NavigationLink(
                route: viewStore.route,
                case: /SettingsState.Route.about,
                onNavigate: { viewStore.send(.navigateAbout($0)) },
                destination: { aboutState in
                  AboutView(
                    store: self.store.scope(
                      state: { _ in aboutState },
                      action: SettingsAction.about
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
              case: /SettingsState.Route.activate,
              onNavigate: { viewStore.send(.navigateActivatePasscode($0)) },
              destination: { activateState in
                ActivatePasscodeView(
                  store: self.store.scope(
                    state: { _ in activateState },
                    action: SettingsAction.activatePasscodeAction
                  )
                )
              },
              label: EmptyView.init
            )
            NavigationLink(
              route: viewStore.route,
              case: /SettingsState.Route.menu,
              onNavigate: { viewStore.send(.navigateMenuPasscode($0)) },
              destination: { menuState in
                MenuPasscodeView(
                  store: self.store.scope(
                    state: { _ in menuState },
                    action: SettingsAction.menuPasscodeAction
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
