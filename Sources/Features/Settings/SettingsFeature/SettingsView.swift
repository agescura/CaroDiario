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
	
	private struct ViewState: Equatable {
		let showSplash: Bool
		let authenticationType: LocalAuthenticationType
		let language: Localizable
		let destination2: SettingsFeature.State.Destination2?
		let hasPasscode: Bool
		let cameraStatus: AuthorizedVideoStatus
		let microphoneStatus: AudioRecordPermission
		
		init(
			state: SettingsFeature.State
		) {
			self.showSplash = state.showSplash
			self.authenticationType = state.authenticationType
			self.language = state.language
			self.destination2 = state.destination2
			self.hasPasscode = state.hasPasscode
			self.cameraStatus = state.cameraStatus
			self.microphoneStatus = state.microphoneStatus
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
			VStack {
				Form {
					Section {
						Toggle(
							isOn: viewStore.binding(
								get: { _ in viewStore.showSplash },
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
								viewStore.send(.navigateToActivate)
							}
						}
					}
					
					Section {
						NavigationLink(
							route: viewStore.destination2,
							case: /SettingsFeature.State.Destination2.camera,
							onNavigate: { viewStore.send(.navigateCamera($0)) },
							destination: { cameraState in
								CameraView(
									store: self.store.scope(
										state: { _ in cameraState },
										action: SettingsFeature.Action.camera
									)
								)
							},
							label: {
								CameraRowView(title: viewStore.cameraStatus.rawValue.localized)
							}
						)
						NavigationLink(
							route: viewStore.destination2,
							case: /SettingsFeature.State.Destination2.microphone,
							onNavigate: { viewStore.send(.navigateMicrophone($0)) },
							destination: { microphoneState in
								MicrophoneView(
									store: self.store.scope(
										state: { _ in microphoneState },
										action: SettingsFeature.Action.microphone
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
							route: viewStore.destination2,
							case: /SettingsFeature.State.Destination2.export,
							onNavigate: { viewStore.send(.navigateExport($0)) },
							destination: { exportState in
								ExportView(
									store: self.store.scope(
										state: { _ in exportState },
										action: SettingsFeature.Action.export
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
						NavigationLinkStore(
							self.store.scope(state: \.$destination, action: SettingsFeature.Action.destination),
							state: /SettingsFeature.Destination.State.agreements,
							action: SettingsFeature.Destination.Action.agreements,
							onTap: { viewStore.send(.agreementsButtonTapped) },
							destination: AgreementsView.init(store:),
							label: AgreementsRowView.init
						)
						
						NavigationLink(
							route: viewStore.destination2,
							case: /SettingsFeature.State.Destination2.about,
							onNavigate: { viewStore.send(.navigateAbout($0)) },
							destination: { aboutState in
								AboutView(
									store: self.store.scope(
										state: { _ in aboutState },
										action: SettingsFeature.Action.about
									)
								)
							},
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
					NavigationLink(
						route: viewStore.destination2,
						case: /SettingsFeature.State.Destination2.menu,
						onNavigate: { viewStore.send(.navigateMenu($0)) },
						destination: { menuState in
							MenuPasscodeView(
								store: self.store.scope(
									state: { _ in menuState },
									action: SettingsFeature.Action.menu
								)
							)
						},
						label: EmptyView.init
					)
				}
				.frame(height: 0)
			}
			.onAppear { viewStore.send(.onAppear) }
		}
	}
}
