import SwiftUI
import ComposableArchitecture
import DesignSystem
import PasscodeFeature
import Models
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature

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
								status: store.userSettings.language.localizable.localized
							)
						}
					}
					
					Section {
						Button {
							store.send(.navigateToPasscode)
						} label: {
							PasscodeRowView(
								title: "Settings.Code".localized(with: [store.userSettings.localAuthenticationType.rawValue]),
								status: store.userSettings.hasPasscode ? "Settings.On".localized : "Settings.Off".localized
							)
						}
					}
					
					Section {
						NavigationLink(
							state: SettingsFeature.Path.State.camera(CameraFeature.State())
						) {
							CameraRowView(title: store.userSettings.authorizedVideoStatus.rawValue.localized)
						}
						NavigationLink(
							state: SettingsFeature.Path.State.microphone(MicrophoneFeature.State())
						) {
							MicrophoneRowView(title: store.userSettings.audioRecordPermission.title.localized)
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

//import EntriesFeature

#Preview {
	SettingsView(
		store: Store(
			initialState: SettingsFeature.State(
				path: StackState(
					[
//              .appearance(AppearanceFeature()),
//            .style(StyleFeature.State(entries: fakeEntries))
					]
				)
			),
			reducer: { SettingsFeature() }
		)
	)
}
