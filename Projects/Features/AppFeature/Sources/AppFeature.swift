import ComposableArchitecture
import Foundation
import HomeFeature
import LockScreenFeature
import Models
import OnboardingFeature
import SplashFeature

@Reducer
public struct AppFeature {
	public init() {}
	
	@Reducer(state: .equatable, action: .equatable)
	public enum Scene {
		case home(HomeFeature)
		case lockScreen(LockScreenFeature)
		case onboarding(WelcomeFeature)
		case splash(SplashFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		public var appDelegate: AppDelegateState
		public var isFirstStarted = true
		public var isBiometricAlertPresent = false
		public var scene: Scene.State
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public enum State {
			case active
			case background
			case inactive
			case unknown
		}

		public init(
			appDelegate: AppDelegateState = AppDelegateState(),
			scene: Scene.State = .splash(SplashFeature.State())
		) {
			self.appDelegate = appDelegate
			self.scene = scene
		}
	}
	
	@CasePathable
	public enum Action: Equatable {
		case appDelegate(AppDelegateAction)
		case authorizationStatusResponse(AuthorizedVideoStatus)
		case biometricAlertPresent(Bool)
		case process(URL)
		case scene(Scene.Action)
		case setUserInterfaceStyle
		case shortcuts
		case splashFinished
		case startHome(cameraStatus: AuthorizedVideoStatus)
		case state(AppFeature.State.State)
	}
	
	@Dependency(\.userDefaultsClient) var userDefaultsClient
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
	@Dependency(\.mainQueue) var mainQueue
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.avAudioSessionClient) var avAudioSessionClient
	@Dependency(\.coreDataClient) var coreDataClient
	@Dependency(\.uuid) var uuid
	private enum CancelID {
		case coreData
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.appDelegate, action: \.appDelegate) {
			EmptyReducer()
		}
		Scope(state: \.scene, action: \.scene) {
			Scene.body
		}
		Reduce { state, action in
			switch action {
				case .appDelegate(.didFinishLaunching):
					return .merge(
						.run { [userInterfaceStyle = state.userSettings.appearance.themeType.userInterfaceStyle] _ in
							await self.applicationClient.setUserInterfaceStyle(userInterfaceStyle)
						},
						.run { [showSplash = state.userSettings.showSplash] send in
							if !showSplash {
								await send(.splashFinished)
							}
						},
						.run { send in
							await send(.authorizationStatusResponse(self.avCaptureDeviceClient.authorizationStatus()))
						}
					)
					
				case let .authorizationStatusResponse(authorizedVideoStatus):
					state.userSettings.authorizedVideoStatus = authorizedVideoStatus
					return .none
					
				case .splashFinished:
					if state.userSettings.hasPasscode {
						state.scene = .lockScreen(LockScreenFeature.State())
						return .none
					}
					if !state.userSettings.hasShownOnboarding {
						state.scene = .onboarding(WelcomeFeature.State())
						return .none
					}
					state.scene = .home(HomeFeature.State())
					return .none
					
				case let .scene(sceneAction):
					switch sceneAction {
						case .lockScreen(.delegate(.matchedCode)):
							state.scene = .home(HomeFeature.State())
							return .none
						case .onboarding(.delegate(.navigateToHome)):
							state.scene = .home(HomeFeature.State())
							return .none
						case .splash(.delegate(.animationFinished)):
							return .send(.splashFinished)
						default:
							return .none
					}
					
				default:
					return .none
			}
		}
//		Reduce(self.coreData)
//		Reduce(self.userDefaults)
	}
	
//	private func core(
//		state: inout State,
//		action: Action
//	) -> Effect<Action> {
//		switch action {
//			case .appDelegate(.didFinishLaunching):
//				return .send(.setUserInterfaceStyle)
//				
//			case .setUserInterfaceStyle:
//				return .run { send in
//					await self.applicationClient.setUserInterfaceStyle(self.userDefaultsClient.themeType.userInterfaceStyle)
//				}
//				
//			case .scene(.splash(.finishAnimation)):
//				if state.userSettings.hasShownOnboarding {
//					if let code = self.userDefaultsClient.passcodeCode {
//						state.scene = .lockScreen(LockScreenFeature.State())
//						return .none
//					} else {
//						return .run { send in
//							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
//						}
//					}
//				}
//				
//				state.scene = .onboarding(WelcomeFeature.State())
//				return .none
//				
////			case .scene(.onboarding(.delegate(.goToHome))),
////					.scene(.onboarding(.privacy(.delegate(.goToHome)))),
////					.scene(.onboarding(.privacy(.style(.delegate(.goToHome))))),
////					.scene(.onboarding(.privacy(.style(.layout(.delegate(.goToHome)))))):
////				return .send(RootFeature.Action.requestCameraStatus)
////
////			case .scene(.onboarding(.privacy(.style(.layout(.theme(.startButtonTapped)))))):
////				return .run { send in
////					try await self.mainQueue.sleep(for: 0.001)
////					await send(.requestCameraStatus)
////				}
//				
////			case .scene(.lockScreen(.matchedCode)):
////				return .run { send in
////					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
////				}
//				
////			case .scene(.home(.settings(.menu(.toggleFaceId(true))))),
////					.scene(.home(.settings(.activate(.insert(.menu(.toggleFaceId(isOn: true))))))),
////					.scene(.lockScreen(.checkFaceId)):
////				return .send(.biometricAlertPresent(true))
////				
////			case .scene(.home(.settings(.menu(.faceId(response:))))),
////					.scene(.home(.settings(.activate(.insert(.menu(.faceId(response:))))))),
////					.scene(.lockScreen(.faceIdResponse)):
////				return .run { send in
////					try await self.mainQueue.sleep(for: 10)
////					await send(.biometricAlertPresent(false))
////				}
//				
//			case .scene:
//				return .none
//				
////			case .requestCameraStatus:
////				return .run { send in
////					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
////				}
//				
//			case let .startHome(cameraStatus: status):
//				return .none
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
//					 timeForAskPasscode > self.now {
//					return .none
//				}
//				if let code = self.userDefaultsClient.passcodeCode {
//					state.scene = .lockScreen(LockScreenFeature.State())
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
//					return .run { _ in await self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode) }
//				}
//				return .run { _ in await self.userDefaultsClient.removeOptionTimeForAskPasscode() }
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
//				
//			default:
//				return .none
//		}
//	}
	
//	private func coreData(
//		state: inout State,
//		action: Action
//	) -> Effect<Action> {
//		if case .home = state.scene {
//			switch action {
//				case .scene(.home(.entries(.onAppear))):
//					return .run { send in
//						for await entries in await self.coreDataClient.subscriber() {
//							await send(.scene(.home(.entries(.coreDataClientAction(.entries(entries))))))
//						}
//					}
//				case let .scene(.home(.entries(.remove(entry)))):
//					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
//
//				case .scene(.home(.settings(.export(.processPDF)))):
//					return .run { send in
//						await send(
//							.scene(.home(.settings(.export(.generatePDF(self.coreDataClient.fetchAll())))))
//						)
//					}
//
//				case .scene(.home(.settings(.export(.previewPDF)))):
//					return .run { send in
//						await send(
//							.scene(.home(.settings(.export(.generatePreview(self.coreDataClient.fetchAll())))))
//						)
//					}
//
//				case let .scene(.home(.search(.searching(newText: newText)))):
//					return .run { send in
//						await send(
//							.scene(.home(.search(.searchResponse(self.coreDataClient.searchEntries(newText)))))
//						)
//					}
//
//				case .scene(.home(.search(.navigateImageSearch))):
//					return .run { send in
//						await send(.scene(.home(.search(.navigateSearch(.images, self.coreDataClient.searchImageEntries())))))
//					}
//
//				case .scene(.home(.search(.navigateVideoSearch))):
//					return .run { send in
//						await send(.scene(.home(.search(.navigateSearch(.videos, self.coreDataClient.searchVideoEntries())))))
//					}
//
//				case .scene(.home(.search(.navigateAudioSearch))):
//					return .run { send in
//						await send(.scene(.home(.search(.navigateSearch(.audios, self.coreDataClient.searchAudioEntries())))))
//					}
//
//				case let .scene(.home(.search(.remove(entry)))):
//					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
//
//				case let .scene(.home(.search(.entryDetailAction(.alert(.presented(.remove(entry))))))):
//					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
//
//				default:
//					break
//			}
//		}
//
//		//		if case let .home(homeState) = state.featureState,
//		//			 let entryDetailState = homeState.entries.entryDetailState {
//		//			switch action {
//		//				case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
//		//					return .run { send in
//		//						await send(
//		//							.featureAction(
//		//								.home(
//		//									.entries(
//		//										.detail(
//		//											.entryResponse(
//		//												self.coreDataClient.fetchEntry(entryDetailState.entry)
//		//											)
//		//										)
//		//									)
//		//								)
//		//							)
//		//						)
//		//					}
//		//				case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
//		//					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
//		//
//		//				default:
//		//					break
//		//			}
//		//		}
//
//		if case let .home(homeState) = state.scene,
//			 let addEntryState = homeState.entries.addEntryState {
//			switch action {
//				case .scene(.home(.entries(.addEntryAction(.createDraftEntry)))):
//					return .run { _ in
//						await self.coreDataClient.createDraft(addEntryState.entry)
//					}
//
//				case .scene(.home(.entries(.addEntryAction(.addButtonTapped)))):
//					let entryText = EntryText(
//						id: self.uuid(),
//						message: addEntryState.entry.text.message,
//						lastUpdated: self.now
//					)
//					return .run { _ in
//						await self.coreDataClient.updateMessage(entryText, addEntryState.entry)
//						await self.coreDataClient.publishEntry(addEntryState.entry)
//					}
//
//				case let .scene(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))):
//					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id) }
//
//				case let .scene(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))):
//					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id) }
//
//				case let .scene(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))):
//					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id) }
//
//				case let .scene(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))):
//					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
//
//				case .scene(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))):
//					return .run { _ in await self.coreDataClient.removeEntry(addEntryState.entry.id) }
//
//				default:
//					break
//			}
//		}
//		return .none
//	}
//
//	private func userDefaults(
//		state: inout State,
//		action: Action
//	) -> Effect<Action> {
//		switch action {
//			case let .scene(.home(.settings(.appearance(.layout(.layoutChanged(layout)))))):
//				return .run { _ in await self.userDefaultsClient.set(layoutType: layout) }
//			case let .scene(.home(.settings(.appearance(.style(.styleChanged(style)))))):
//				return .run { _ in await self.userDefaultsClient.set(styleType: style) }
//			case let .scene(.home(.settings(.appearance(.theme(.themeChanged(theme)))))):
//				return .run { _ in await self.userDefaultsClient.set(themeType: theme) }
//			case let .scene(.home(.settings(.toggleShowSplash(isOn: isOn)))):
//				return .run { _ in await self.userDefaultsClient.setHideSplashScreen(!isOn) }
//			case .scene(.home(.settings(.activate(.insert(.menu(.dialog(.presented(.turnOff)))))))),
//					.scene(.home(.settings(.menu(.dialog(.presented(.turnOff)))))):
//				return .run { _ in await self.userDefaultsClient.removePasscode() }
//			case let .scene(.home(.settings(.activate(.insert(.update(code: code)))))):
//				return .run { _ in await self.userDefaultsClient.setPasscode(code) }
//			case let .scene(.home(.settings(.menu(.faceId(response: faceId))))),
//				let .scene(.home(.settings(.activate(.insert(.menu(.faceId(response: faceId))))))):
//				return .run { _ in await self.userDefaultsClient.setFaceIDActivate(faceId) }
//			case let .scene(.home(.settings(.menu(.optionTimeForAskPasscode(changed: newOption))))),
//				let .scene(.home(.settings(.activate(.insert(.menu(.optionTimeForAskPasscode(changed: newOption))))))):
//				return .run { _ in await self.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value) }
//			case .scene(.home(.settings(.activate(.insert(.navigateMenu(true)))))):
//				return .run { _ in await self.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value) }
//			case let .scene(.home(.settings(.language(.updateLanguageTapped(language))))):
//				return .run { _ in await self.userDefaultsClient.setLanguage(language.rawValue) }
//			case let .scene(.onBoarding(.privacy(.style(.styleChanged(styleChanged))))):
//				return .run { _ in await self.userDefaultsClient.set(styleType: styleChanged) }
//			case let .scene(.onBoarding(.privacy(.style(.layout(.layoutChanged(layoutChanged)))))):
//				return .run { _ in await self.userDefaultsClient.set(layoutType: layoutChanged) }
//			case let .scene(.onBoarding(.privacy(.style(.layout(.theme(.themeChanged(themeChanged))))))):
//				return .run { _ in await self.userDefaultsClient.set(themeType: themeChanged) }
//			default:
//				break
//		}
//		return .none
//	}
}
