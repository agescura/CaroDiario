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
							NavigationLink(
								state: SettingsFeature.Path.State.camera(CameraFeature.State())
							) {
								CameraRowView(title: self.store.userSettings.authorizedVideoStatus.rawValue.localized)
							}
							NavigationLink(
								state: SettingsFeature.Path.State.microphone(MicrophoneFeature.State())
							) {
								MicrophoneRowView(title: self.store.userSettings.audioRecordPermission.title.localized)
							}
            }
            
            Section {
							NavigationLink(
								state: SettingsFeature.Path.State.export(ExportFeature.State())
							) {
								ExportRowView()
							}
            }
            
            Section {
              ReviewRowView()
                .contentShape(Rectangle())
                .onTapGesture {
									self.store.send(.reviewStoreKit)
                }
            }
            
						Section {
							NavigationLink(
								state: SettingsFeature.Path.State.agreements(AgreementsFeature.State())
							) {
								AgreementsRowView()
							}
							NavigationLink(
								state: SettingsFeature.Path.State.about(AboutFeature.State())
							) {
								AboutRowView()
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
			.task { await self.store.send(.task).finish() }
    }
  }
}

import EntriesFeature

#Preview {
	SettingsView(
		store: Store(
			initialState: SettingsFeature.State(
				path: StackState(
					[
//						.appearance(AppearanceFeature.State()),
//						.style(StyleFeature.State(entries: fakeEntries))
					]
				)
			),
			reducer: { SettingsFeature() }
		)
	)
}
