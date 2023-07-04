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
	let store: StoreOf<SettingsFeature>
	
	public init(
		store: StoreOf<SettingsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.userSettings
		) { viewStore in
			VStack {
				Form {
					Section {
						Toggle(
							isOn: viewStore.binding(
								get: { _ in viewStore.state.showSplash },
								send: SettingsFeature.Action.toggleShowSplash
							),
							label: SplashRowView.init
						)
						.toggleStyle(SwitchToggleStyle(tint: .chambray))
						
						NavigationLinkStore(
							self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
							state: /SettingsFeature.Destination.State.appearance,
							action: SettingsFeature.Destination.Action.appearance,
							onTap: { viewStore.send(.appearanceButtonTapped) },
							destination: AppearanceView.init(store:),
							label: AppearanceRowView.init
						)
					}
					
					Section {
						NavigationLinkStore(
							self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
							state: /SettingsFeature.Destination.State.language,
							action: SettingsFeature.Destination.Action.language,
							onTap: { viewStore.send(.languageButtonTapped) },
							destination: LanguageView.init(store:),
							label: {
								LanguageRowView(
									title: "Settings.Language"/*.localized(with: [viewStore.authenticationType.rawValue])*/,
									status: viewStore.language.localizable.localized
								)
							}
						)
					}
					
					Section {
						PasscodeRowView(
							title: "Settings.Code"/*.localized(with: [viewStore.authenticationType.rawValue])*/,
							status: viewStore.state.passcode.count > 0 ? "Settings.On".localized : "Settings.Off".localized
						)
						.contentShape(Rectangle())
						.onTapGesture {
							if viewStore.state.passcode.count > 0 {
								viewStore.send(.navigateToMenu)
							} else {
								viewStore.send(.navigateToActivate)
							}
						}
					}
					
					Section {
                  NavigationLinkStore(
                     self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
                     state: /SettingsFeature.Destination.State.camera,
                     action: SettingsFeature.Destination.Action.camera,
                     onTap: { viewStore.send(.cameraButtonTapped) },
                     destination: CameraView.init(store:),
                     label: {
                        CameraRowView(title: "viewStore.cameraStatus.rawValue.localized")
                     }
                  )
                  
                  NavigationLinkStore(
                     self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
                     state: /SettingsFeature.Destination.State.microphone,
                     action: SettingsFeature.Destination.Action.microphone,
                     onTap: { viewStore.send(.microphoneButtonTapped) },
                     destination: MicrophoneView.init(store:),
                     label: {
                        MicrophoneRowView(title: "viewStore.microphoneStatus.title.localized")
                     }
                  )
					}
					
					Section {
                  NavigationLinkStore(
                     self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
                     state: /SettingsFeature.Destination.State.export,
                     action: SettingsFeature.Destination.Action.export,
                     onTap: { viewStore.send(.exportButtonTapped) },
                     destination: ExportView.init(store:),
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
						NavigationLinkStore(
							self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
							state: /SettingsFeature.Destination.State.agreements,
							action: SettingsFeature.Destination.Action.agreements,
							onTap: { viewStore.send(.agreementsButtonTapped) },
							destination: AgreementsView.init(store:),
							label: AgreementsRowView.init
						)
						
						NavigationLinkStore(
							self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
							state: /SettingsFeature.Destination.State.about,
							action: SettingsFeature.Destination.Action.about,
							onTap: { viewStore.send(.aboutButtonTapped) },
							destination: AboutView.init(store:),
							label: AboutRowView.init
						)
					}
				}
				
				VStack {
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
						state: /SettingsFeature.Destination.State.activate,
						action: SettingsFeature.Destination.Action.activate,
						destination: ActivateView.init(store:),
						label: EmptyView.init
					)
               NavigationLinkStore(
                  self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
                  state: /SettingsFeature.Destination.State.menu,
                  action: SettingsFeature.Destination.Action.menu,
                  destination: MenuPasscodeView.init(store:),
                  label: EmptyView.init
               )
				}
				.frame(height: 0)
			}
			.onAppear { viewStore.send(.onAppear) }
		}
	}
}

struct SettingsView_Preview: PreviewProvider {
  static var previews: some View {
	 NavigationView {
		 SettingsView(
			store: Store(
				initialState: SettingsFeature.State(
					userSettings: .defaultValue
				),
				reducer: SettingsFeature()
			)
		 )
	 }
  }
}
