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
	@Perception.Bindable var store: StoreOf<SettingsFeature>
  
  public init(
    store: StoreOf<SettingsFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
			NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
        VStack {
          Form {
            Section {
              Toggle(
								isOn: self.$store.userSettings.showSplash.sending(\.toggleShowSplash),
                label: SplashRowView.init
              )
              .toggleStyle(SwitchToggleStyle(tint: .chambray))
              
							NavigationLink(
								state: SettingsFeature.Path.State.appearance(AppearanceFeature.State())
							) {
								AppearanceRowView()
							}
            }
            
            Section {
							NavigationLink(
								state: SettingsFeature.Path.State.language(LanguageFeature.State())
							) {
								LanguageRowView(
									title: "Settings.Language".localized,
									status: self.store.userSettings.language.localizable.localized
								)
							}
            }
            
            Section {
							Button {
								self.store.send(.navigateToPasscode)
							} label: {
								PasscodeRowView(
									title: "Settings.Code".localized(with: [self.store.localAuthenticationType.rawValue]),
									status: self.store.userSettings.hasPasscode ? "Settings.On".localized : "Settings.Off".localized
								)
							}
            }
            
            Section {
//              NavigationLink(
//                route: viewStore.destination,
//                case: /Settings.State.Destination.camera,
//                onNavigate: { viewStore.send(.navigateCamera($0)) },
//                destination: { cameraState in
//                  CameraView(
//                    store: self.store.scope(
//                      state: { _ in cameraState },
//                      action: Settings.Action.camera
//                    )
//                  )
//                },
//                label: {
//                  CameraRowView(title: viewStore.cameraStatus.rawValue.localized)
//                }
//              )
//              NavigationLink(
//                route: viewStore.destination,
//                case: /Settings.State.Destination.microphone,
//                onNavigate: { viewStore.send(.navigateMicrophone($0)) },
//                destination: { microphoneState in
//                  MicrophoneView(
//                    store: self.store.scope(
//                      state: { _ in microphoneState },
//                      action: Settings.Action.microphone
//                    )
//                  )
//                },
//                label: {
//                  MicrophoneRowView(title: viewStore.microphoneStatus.title.localized)
//                }
//              )
            }
            
            Section {
//              NavigationLink(
//                route: viewStore.destination,
//                case: /Settings.State.Destination.export,
//                onNavigate: { viewStore.send(.navigateExport($0)) },
//                destination: { exportState in
//                  ExportView(
//                    store: self.store.scope(
//                      state: { _ in exportState },
//                      action: Settings.Action.export
//                    )
//                  )
//                },
//                label: ExportRowView.init
//              )
            }
            
            Section {
              ReviewRowView()
                .contentShape(Rectangle())
                .onTapGesture {
									self.store.send(.reviewStoreKit)
                }
            }
            
            Section {
//              NavigationLink(
//                route: viewStore.destination,
//                case: /Settings.State.Destination.agreements,
//                onNavigate: { viewStore.send(.navigateAgreements($0)) },
//                destination: { agreementsState in
//                  AgreementsView(
//                    store: self.store.scope(
//                      state: { _ in agreementsState },
//                      action: Settings.Action.agreements
//                    )
//                  )
//                },
//                label: AgreementsRowView.init
//              )
//              NavigationLink(
//                route: viewStore.destination,
//                case: /Settings.State.Destination.about,
//                onNavigate: { viewStore.send(.navigateAbout($0)) },
//                destination: { aboutState in
//                  AboutView(
//                    store: self.store.scope(
//                      state: { _ in aboutState },
//                      action: Settings.Action.about
//                    )
//                  )
//                },
//                label: AboutRowView.init
//              )
            }
          }
          
          VStack {
//            NavigationLink(
//              route: viewStore.destination,
//              case: /Settings.State.Destination.activate,
//              onNavigate: { viewStore.send(.navigateActivate($0)) },
//              destination: { activateState in
//                ActivateView(
//                  store: self.store.scope(
//                    state: { _ in activateState },
//                    action: Settings.Action.activate
//                  )
//                )
//              },
//              label: EmptyView.init
//            )
//            NavigationLink(
//              route: viewStore.destination,
//              case: /Settings.State.Destination.menu,
//              onNavigate: { viewStore.send(.navigateMenu($0)) },
//              destination: { menuState in
//                MenuPasscodeView(
//                  store: self.store.scope(
//                    state: { _ in menuState },
//                    action: Settings.Action.menu
//                  )
//                )
//              },
//              label: EmptyView.init
//            )
          }
          .frame(height: 0)
        }
        .navigationTitle("Settings.Title".localized)
			} destination: { store in
				switch store.case {
					case let .activate(store):
						ActivateView(store: store)
					case let .appearance(store):
						AppearanceView(store: store)
					case let .camera(store):
						CameraView(store: store)
					case let .iconApp(store):
						IconAppView(store: store)
					case let .insert(store):
						InsertView(store: store)
					case let .language(store):
						LanguageView(store: store)
					case let .layout(store: store):
						LayoutView(store: store)
					case let .menu(store):
						MenuPasscodeView(store: store)
					case let .style(store):
						StyleView(store: store)
					case let .theme(store):
						ThemeView(store: store)
				}
			}
      .navigationViewStyle(StackNavigationViewStyle())
			.task { await self.store.send(.task).finish() }
    }
  }
}

#Preview {
	SettingsView(
		store: Store(
			initialState: SettingsFeature.State(),
			reducer: { SettingsFeature() }
		)
	)
}
