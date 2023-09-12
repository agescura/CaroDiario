import AppFeature
import AddEntryFeature
import ComposableArchitecture
import EntriesFeature
import Foundation
import LockScreenFeature
import HomeFeature
import Models
import OnboardingFeature
import PasscodeFeature
import SettingsFeature
import SplashFeature

public struct RootFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var app: AppReducer.State = .splash(SplashFeature.State())
		public var userSettings: UserSettings = .defaultValue
		
		public var isFirstStarted = true
		public var isBiometricAlertPresent = false
		
		public enum State {
			case active
			case inactive
			case background
			case unknown
		}
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case app(AppReducer.Action)
		case didFinishLaunching
		case userSettingsResponse(UserSettings)
		
		case requestCameraStatus
		case startHome(cameraStatus: AuthorizedVideoStatus)
		
		case process(URL)
		case state(RootFeature.State.State)
		case shortcuts
		
		case biometricAlertPresent(Bool)
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avAudioRecorderClient) private var avAudioRecorderClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.coreDataClient) private var coreDataClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	private enum CancelID {
		case coreData
	}
	
	public var body: some ReducerOf<Self> {
//		Reduce(self.coreData)
//		Reduce(self.userDefaults)
		Scope(state: \.app, action: /Action.app) {
			AppReducer()
		}
		Reduce { state, action in
			switch action {
				case .app:
					return .none

				case .didFinishLaunching:
					return .run { send in
						let userSettings = self.userDefaultsClient.userSettings()
						await self.applicationClient.setUserInterfaceStyle(userSettings.appearance.themeType.userInterfaceStyle)
						await send(.userSettingsResponse(userSettings))
					}
					
				case let .userSettingsResponse(userSettings):
					state.userSettings = userSettings
					
					if userSettings.showSplash {
						return .none
					}
					
					if !userSettings.passcode.isEmpty {
						state.app = .lockScreen(LockScreenFeature.State(code: userSettings.passcode))
						return .none
					}
					
					if !userSettings.hasShownOnboarding {
						state.app = .onBoarding(WelcomeFeature.State())
						return .none
					}
					
					return .none
					
				default:
					return .none
//				case .setUserInterfaceStyle:
//					<#code#>
//				case .startFirstScreen:
//					<#code#>
//				case .requestCameraStatus:
//					<#code#>
//				case .startHome(cameraStatus: let cameraStatus):
//					<#code#>
//				case .process(_):
//					<#code#>
//				case .state(_):
//					<#code#>
//				case .shortcuts:
//					<#code#>
//				case .biometricAlertPresent(_):
//					<#code#>
			}
		}
	}
	
//	private func core(
//		state: inout State,
//		action: Action
//	) -> Effect<Action> {
//		switch action {
//			case .didFinishLaunching:
//				return .send(.setUserInterfaceStyle)
//
//			case .setUserInterfaceStyle:
//				return .run { @MainActor send in
//					await self.applicationClient.setUserInterfaceStyle(self.userDefaultsClient.themeType.userInterfaceStyle)
//					send(.startFirstScreen)
//				}
//
//			case .featureAction(.splash(.delegate(.finishAnimation))):
//				if self.userDefaultsClient.hasShownFirstLaunchOnboarding {
//					if let code = self.userDefaultsClient.passcodeCode {
//						state.featureState = .lockScreen(.init(code: code))
//						return .none
//					} else {
//						return .run { send in
//							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
//						}
//					}
//				}
//
//				state.featureState = .onBoarding(.init())
//				return .none
//
//			case .featureAction(.onBoarding(.delegate(.skip))),
//					.featureAction(.onBoarding(.destination(.presented(.privacy(.delegate(.skip)))))),
//					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.delegate(.skip))))))))),
//					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.delegate(.skip)))))))))))):
//				return .send(.requestCameraStatus)
//
//			case .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(.theme(.startButtonTapped)))))))))))))):
//				return .run { send in
//					try await self.mainQueue.sleep(for: .seconds(0.001))
//					await send(.requestCameraStatus)
//				}
//
//			case .featureAction(.lockScreen(.matchedCode)):
//				return .send(.requestCameraStatus)
//
//			case .featureAction(.home(.settings(.destination(.presented(.menu(.toggleFaceId(true))))))),
//					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.toggleFaceId(isOn: true))))))))))),
//					.featureAction(.lockScreen(.checkFaceId)):
//				return .send(.biometricAlertPresent(true))
//
//			case .featureAction(.home(.settings(.destination(.presented(.menu(.faceId(response:))))))),
//					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response:))))))))))),
//					.featureAction(.lockScreen(.faceIdResponse)):
//				return .run { send in
//					try await self.mainQueue.sleep(for: .seconds(10))
//					await send(.biometricAlertPresent(false))
//				}
//
//			case .featureAction:
//				return .none
//
//			case .startFirstScreen:
//				if self.userDefaultsClient.hideSplashScreen {
//					if let code = self.userDefaultsClient.passcodeCode {
//						state.featureState = .lockScreen(.init(code: code))
//						return .none
//					} else {
//						return .run { send in
//							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
//						}
//					}
//				}
//
//				return .none
//
//			case .requestCameraStatus:
//				return .run { send in
//					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
//				}
//
//			case let .startHome(cameraStatus: status):
//				state.isFirstStarted = false
//				state.featureState = .home(
//					.init(
//						tabBars: [.entries, .search, .settings],
//						sharedState: SharedState(
//							showSplash: !self.userDefaultsClient.hideSplashScreen,
//							styleType: self.userDefaultsClient.styleType,
//							layoutType: self.userDefaultsClient.layoutType,
//							themeType: self.userDefaultsClient.themeType,
//							iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light,
//							language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
//							hasPasscode: (self.userDefaultsClient.passcodeCode ?? "").count > 0,
//							cameraStatus: status,
//							recordPermission: self.avAudioRecorderClient.recordPermission(),
//							optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
//							faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
//						),
//						settings: SettingsFeature.State(
//							cameraStatus: status,
//							recordPermission: self.avAudioRecorderClient.recordPermission(),
//							userSettings: UserSettings(
//								showSplash: !self.userDefaultsClient.hideSplashScreen,
//								hasShownOnboarding: true,
//								appearance: AppearanceSettings(
//									styleType: self.userDefaultsClient.styleType,
//									layoutType: self.userDefaultsClient.layoutType,
//									themeType: self.userDefaultsClient.themeType,
//									iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light
//								),
//								language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
//								passcode: self.userDefaultsClient.passcodeCode ?? "",
//								optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
//								faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
//							)
//						)
//					)
//				)
//				return .send(.featureAction(.home(.starting)))
//
//			case .process:
//				return .none
//
//			case .state(.active):
//				if state.isFirstStarted {
//					return .none
//				}
//				if state.isBiometricAlertPresent {
//					return .none
//				}
//				if let timeForAskPasscode = self.userDefaultsClient.timeForAskPasscode,
//					timeForAskPasscode > self.now {
//					return .none
//				}
//				if let code = self.userDefaultsClient.passcodeCode {
//					state.featureState = .lockScreen(.init(code: code))
//					return .none
//				}
//				return .none
//
//			case .state(.background):
//				if let timeForAskPasscode = Calendar.current.date(
//					byAdding: .minute,
//					value: self.userDefaultsClient.optionTimeForAskPasscode,
//					to: self.now
//				) {
//					self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode)
//					return .none
//				}
//				self.userDefaultsClient.removeOptionTimeForAskPasscode()
//				return .none
//
//			case .state:
//				return .none
//
//			case .shortcuts:
//				return .none
//
//			case let .biometricAlertPresent(value):
//				state.isBiometricAlertPresent = value
//				return .none
//		}
//	}
	
	private func coreData(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		if case .home = state.app {
			switch action {
				case .app(.home(.entries(.onAppear))):
					return .run { send in
						for await entries in await self.coreDataClient.subscriber() {
							await send(.app(.home(.entries(.coreDataClientAction(.entries(entries))))))
						}
					}

				case let .app(.home(.entries(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case .app(.home(.settings(.destination(.presented(.export(.processPDF)))))):
					return .run { send in
						await send(
							.app(.home(.settings(.destination(.presented(.export(.generatePDF(self.coreDataClient.fetchAll())))))))
						)
					}
					
				case .app(.home(.settings(.destination(.presented(.export(.previewPDFButtonTapped)))))):
					return .run { send in
						await send(
							.app(.home(.settings(.destination(.presented(.export(.generatePreview(self.coreDataClient.fetchAll())))))))
						)
					}
					
				case let .app(.home(.search(.searching(newText: newText)))):
					return .run { send in
						await send(
							.app(.home(.search(.searchResponse(self.coreDataClient.searchEntries(newText)))))
						)
					}
					
				case .app(.home(.search(.navigateImageSearch))):
					return .run { send in
						await send(.app(.home(.search(.navigateSearch(.images, self.coreDataClient.searchImageEntries())))))
					}
					
				case .app(.home(.search(.navigateVideoSearch))):
					return .run { send in
						await send(.app(.home(.search(.navigateSearch(.videos, self.coreDataClient.searchVideoEntries())))))
					}
					
				case .app(.home(.search(.navigateAudioSearch))):
					return .run { send in
						await send(.app(.home(.search(.navigateSearch(.audios, self.coreDataClient.searchAudioEntries())))))
					}
					
				case let .app(.home(.search(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case let .app(.home(.search(.destination(.presented(.entryDetail(.destination(.presented(.alert(.remove(entry)))))))))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.app,
			case let .detail(entryDetailState) = homeState.entries.destination {
			switch action {
				case .app(.home(.entries(.destination(.presented(.detail(.onAppear)))))):
					return .run { send in
						await send(
							.app(
								.home(
									.entries(
										.destination(
											.presented(
												.detail(
													.entryResponse(
														self.coreDataClient.fetchEntry(entryDetailState.entry)
													)
												)
											)
										)
									)
								)
							)
						)
					}
					
				case let .app(.home(.entries(.destination(.presented(.detail(.removeAttachmentResponse(id))))))):
					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.app,
			let addEntryState = homeState.entries.addEntryState {
			switch action {
				case .app(.home(.entries(.destination(.presented(.addEntry(.createDraftEntry)))))),
						.app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.createDraftEntry))))))))):
					return .run { _ in
						await self.coreDataClient.createDraft(addEntryState.entry)
					}
					
				case .app(.home(.entries(.destination(.presented(.addEntry(.view(.addButtonTapped))))))),
						.app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.view(.addButtonTapped)))))))))):
					let entryText = EntryText(
						id: self.uuid(),
						message: addEntryState.entry.text.message,
						lastUpdated: self.now
					)
					return .run { _ in
						await self.coreDataClient.updateMessage(entryText, addEntryState.entry)
						await self.coreDataClient.publishEntry(addEntryState.entry)
						
					}
				case let .app(.home(.entries(.destination(.presented(.addEntry(.loadImageResponse(entryImage))))))),
					let .app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.loadImageResponse(entryImage)))))))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id) }
					
				case let .app(.home(.entries(.destination(.presented(.addEntry(.loadVideoResponse(entryVideo))))))),
					let .app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.loadVideoResponse(entryVideo)))))))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id) }
					
				case let .app(.home(.entries(.destination(.presented(.addEntry(.loadAudioResponse(entryAudio))))))),
					let .app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.loadAudioResponse(entryAudio)))))))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id) }
					
				case let .app(.home(.entries(.destination(.presented(.addEntry(.removeAttachmentResponse(id))))))),
					let .app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.removeAttachmentResponse(id)))))))))):
					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
					
				case .app(.home(.entries(.destination(.presented(.addEntry(.removeDraftEntryDismissAlert)))))),
						.app(.home(.entries(.destination(.presented(.detail(.destination(.presented(.edit(.removeDraftEntryDismissAlert))))))))):
					return .run { _ in await self.coreDataClient.removeEntry(addEntryState.entry.id) }
					
				default:
					break
			}
		}
		return .none
	}
	
	private func userDefaults(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .app(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.layout(.layoutChanged(layout)))))))))):
				self.userDefaultsClient.set(layoutType: layout)
				return .none
			case let .app(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.style(.styleChanged(style)))))))))):
				self.userDefaultsClient.set(styleType: style)
				return .none
			case let .app(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.theme(.themeChanged(theme)))))))))):
				self.userDefaultsClient.set(themeType: theme)
				return .none
			case let .app(.home(.settings(.toggleShowSplash(isOn: isOn)))):
				self.userDefaultsClient.setHideSplashScreen(!isOn)
				return .none
			case .app(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.delegate(.turnOffPasscode))))))))))),
					.app(.home(.settings(.destination(.presented(.menu(.delegate(.turnOffPasscode))))))):
				self.userDefaultsClient.removePasscode()
				return .none
			case let .app(.home(.settings(.destination(.presented(.activate(.insert(.presented(.update(code: code))))))))):
				self.userDefaultsClient.setPasscode(code)
				return .none
			case let .app(.home(.settings(.destination(.presented(.menu(.faceId(response: faceId))))))),
				let .app(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response: faceId))))))))))):
				self.userDefaultsClient.setFaceIDActivate(faceId)
				return .none
			case let .app(.home(.settings(.destination(.presented(.menu(.optionTimeForAskPasscode(changed: newOption))))))),
				let .app(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.optionTimeForAskPasscode(changed: newOption))))))))))):
				self.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value)
				return .none
			case .app(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menuButtonTapped)))))))):
				self.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value)
				return .none
			case let .app(.home(.settings(.destination(.presented(.language(.updateLanguageTapped(language))))))):
				self.userDefaultsClient.setLanguage(language.rawValue)
				return .none
			case let .app(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.styleChanged(styleChanged))))))))):
				self.userDefaultsClient.set(styleType: styleChanged)
				return .none
			case let .app(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.layoutChanged(layoutChanged)))))))))))):
				self.userDefaultsClient.set(layoutType: layoutChanged)
				return .none
			case let .app(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(
				.theme(.themeChanged(themeChanged))))))))))))))):
				self.userDefaultsClient.set(themeType: themeChanged)
				return .none
			default:
				break
		}
		return .none
	}
}

extension EntriesFeature.State {
	var addEntryState: AddEntryFeature.State? {
		if case let .addEntry(state) = self.destination {
			return state
		}
		if case let .detail(detailState) = self.destination,
			case let .edit(state) = detailState.destination {
			return state
		}
		return nil
	}
}
