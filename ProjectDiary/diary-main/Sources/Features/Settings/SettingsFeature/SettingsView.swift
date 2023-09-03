import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ComposableArchitecture
import ExportFeature
import LanguageFeature
import MicrophoneFeature
import Models
import PasscodeFeature
import SwiftUI
import SwiftUIHelper
import Styles
import Views

public struct SettingsView: View {
	private let store: StoreOf<SettingsFeature>
	
	private struct ViewState: Equatable {
		let authenticationType: LocalAuthenticationType
		let cameraStatus: AuthorizedVideoStatus
		let hasPasscode: Bool
		let language: Localizable
		let microphoneStatus: RecordPermission
		let showSplash: Bool
		
		init(
			state: SettingsFeature.State
		) {
			self.authenticationType = state.authenticationType
			self.cameraStatus = state.cameraStatus
			self.hasPasscode = state.hasPasscode
			self.language = state.language
			self.microphoneStatus = state.recordPermission
			self.showSplash = state.showSplash
		}
	}
	
	public init(
		store: StoreOf<SettingsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			NavigationView {
				VStack {
					Form {
						Section {
							Toggle(
								isOn: viewStore.binding(
									get: \.showSplash,
									send: SettingsFeature.Action.toggleShowSplash
								),
								label: SplashRowView.init
							)
							.toggleStyle(SwitchToggleStyle(tint: .chambray))

							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.appearance,
								action: SettingsFeature.Destination.Action.appearance,
								onTap: { viewStore.send(.appearanceButtonTapped) },
								destination: AppearanceView.init,
								label: AppearanceRowView.init
							)
						}

						Section {
							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.language,
								action: SettingsFeature.Destination.Action.language,
								onTap: { viewStore.send(.languageButtonTapped) },
								destination: LanguageView.init,
								label: {
									LanguageRowView(
										title: "Settings.Language".localized,
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
									viewStore.send(.menuButtonTapped)
								} else {
									viewStore.send(.activateButtonTapped)
								}
							}
						}

						Section {
							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.camera,
								action: SettingsFeature.Destination.Action.camera,
								onTap: { viewStore.send(.cameraButtonTapped) },
								destination: CameraView.init,
								label: { CameraRowView(title: viewStore.cameraStatus.rawValue.localized) }
							)
							
							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.microphone,
								action: SettingsFeature.Destination.Action.microphone,
								onTap: { viewStore.send(.microphoneButtonTapped) },
								destination: MicrophoneView.init,
								label: { MicrophoneRowView(title: viewStore.microphoneStatus.title.localized) }
							)
						}

						Section {
							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.export,
								action: SettingsFeature.Destination.Action.export,
								onTap: { viewStore.send(.exportButtonTapped) },
								destination: ExportView.init,
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
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.agreements,
								action: SettingsFeature.Destination.Action.agreements,
								onTap: { viewStore.send(.agreementsButtonTapped) },
								destination: AgreementsView.init,
								label: AgreementsRowView.init
							)
							
							NavigationLinkStore(
								self.store.scope(
									state: \.$destination,
									action: SettingsFeature.Action.destination
								),
								state: /SettingsFeature.Destination.State.about,
								action: SettingsFeature.Destination.Action.about,
								onTap: { viewStore.send(.aboutButtonTapped) },
								destination: AboutView.init,
								label: AboutRowView.init
							)
						}
					}

					VStack {
						NavigationLinkStore(
							self.store.scope(
								state: \.$destination,
								action: SettingsFeature.Action.destination
							),
							state: /SettingsFeature.Destination.State.activate,
							action: SettingsFeature.Destination.Action.activate,
							destination: ActivateView.init
						)

						NavigationLinkStore(
							self.store.scope(
								state: \.$destination,
								action: SettingsFeature.Action.destination
							),
							state: /SettingsFeature.Destination.State.menu,
							action: SettingsFeature.Destination.Action.menu,
							destination: MenuPasscodeView.init
						)
					}
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

import EntriesFeature

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView(
			store: Store(
				initialState: SettingsFeature.State(
					cameraStatus: .notDetermined,
					destination: .appearance(
						AppearanceFeature.State(
							appearanceSettings: .defaultValue,
							destination: .layout(
								LayoutFeature.State(
									layoutType: .horizontal,
									styleType: .rectangle,
									entries: fakeEntries(
										with: .rectangle,
										layout: .horizontal
									)
								)
							)
						)
					),
					microphoneStatus: .undetermined,
					userSettings: .defaultValue
				),
				reducer: SettingsFeature.init
			)
		)
	}
}
