import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ComposableArchitecture
import DesignSystem
import ExportFeature
import LanguageFeature
import MicrophoneFeature
import Models
import PasscodeFeature
import SwiftUI

public struct SettingsView: View {
	@Bindable var store: StoreOf<SettingsFeature>
	
	public init(
		store: StoreOf<SettingsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
			VStack {
				Form {
					Section {
						Toggle(
							isOn: $store.userSettings.showSplash.sending(\.toggleShowSplash),
              label: { SettingsRowView(type: .splash) }
						)
						.toggleStyle(SwitchToggleStyle(tint: .chambray))
						
						NavigationLink(
							state: SettingsFeature.Path.State.appearance(AppearanceFeature.State())
						) {
              SettingsRowView(type: .appearance)
						}
					}
					
					Section {
						NavigationLink(
							state: SettingsFeature.Path.State.language(LanguageFeature.State())
						) {
              SettingsRowView(type: .language(store.userSettings.language))
						}
					}
					
					Section {
            if store.userSettings.hasPasscode {
              NavigationLink(
                state: SettingsFeature.Path.State.menu(MenuFeature.State())
              ) {
                SettingsRowView(type: .menu(store.userSettings.localAuthenticationType))
              }
            } else {
              NavigationLink(
                state: SettingsFeature.Path.State.insert(InsertFeature.State())
              ) {
                SettingsRowView(type: .insert(store.userSettings.localAuthenticationType))
              }
            }
					}
					
					Section {
						NavigationLink(
							state: SettingsFeature.Path.State.camera(CameraFeature.State())
						) {
              SettingsRowView(type: .camera(store.userSettings.authorizedVideoStatus.rawValue.localized))
						}
						NavigationLink(
							state: SettingsFeature.Path.State.microphone(MicrophoneFeature.State())
						) {
              SettingsRowView(type: .microphone(store.userSettings.audioRecordPermission.title.localized))
						}
					}
					
					Section {
						NavigationLink(
							state: SettingsFeature.Path.State.export(ExportFeature.State())
						) {
              SettingsRowView(type: .export)
						}
					}
					
					Section {
            SettingsRowView(type: .review)
							.contentShape(Rectangle())
							.onTapGesture {
								store.send(.reviewStoreKit)
							}
					}
					
					Section {
						NavigationLink(
							state: SettingsFeature.Path.State.agreements(AgreementsFeature.State())
						) {
              SettingsRowView(type: .agreements)
						}
						NavigationLink(
							state: SettingsFeature.Path.State.about(AboutFeature.State())
						) {
              SettingsRowView(type: .about)
						}
					}
				}
			}
			.navigationTitle("Settings.Title".localized)
		} destination: { store in
			switch store.case {
				case let .about(store):
					AboutView(store: store)
				case let .activate(store):
					ActivateView(store: store)
				case let .agreements(store):
					AgreementsView(store: store)
				case let .appearance(store):
					AppearanceView(store: store)
				case let .camera(store):
					CameraView(store: store)
				case let .export(store):
					ExportView(store: store)
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
				case let .microphone(store):
					MicrophoneView(store: store)
				case let .style(store):
					StyleView(store: store)
				case let .theme(store):
					ThemeView(store: store)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.task { await store.send(.task).finish() }
	}
}

struct SettingsPreviews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      store: Store(
        initialState: SettingsFeature.State(
          path: {
            let state = StackState<SettingsFeature.Path.State>()
//            state.append(SettingsFeature.Path.State.appearance(AppearanceFeature.State()))
            return state
          }()
        ),
        reducer: { SettingsFeature() }
      )
    )
  }
}
