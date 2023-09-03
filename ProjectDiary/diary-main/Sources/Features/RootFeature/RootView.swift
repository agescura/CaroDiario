import AddEntryFeature
import AppFeature
import ComposableArchitecture
import CoreDataClient
import EntriesFeature
import Models
import PasscodeFeature
import SettingsFeature
import SwiftUI
import UIApplicationClient
import HomeFeature

public struct RootFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var appDelegate: AppDelegateState
		public var featureState: AppReducer.State
		
		public var isFirstStarted = true
		public var isBiometricAlertPresent = false
		
		public enum State {
			case active
			case inactive
			case background
			case unknown
		}
		
		public init(
			appDelegate: AppDelegateState,
			featureState: AppReducer.State
		) {
			self.appDelegate = appDelegate
			self.featureState = featureState
		}
	}
	
	public enum Action: Equatable {
		case appDelegate(AppDelegateAction)
		case featureAction(AppReducer.Action)
		
		case setUserInterfaceStyle
		case startFirstScreen
		
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
		Reduce(self.coreData)
		Reduce(self.userDefaults)
		Scope(state: \.appDelegate, action: /Action.appDelegate) {
			EmptyReducer()
		}
		Scope(state: \.featureState, action: /Action.featureAction) {
			AppReducer()
		}
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case .appDelegate(.didFinishLaunching):
				return .send(.setUserInterfaceStyle)
				
			case .setUserInterfaceStyle:
				return .run { @MainActor send in
					await self.applicationClient.setUserInterfaceStyle(self.userDefaultsClient.themeType.userInterfaceStyle)
					send(.startFirstScreen)
				}
				
			case .featureAction(.splash(.delegate(.finishAnimation))):
				if self.userDefaultsClient.hasShownFirstLaunchOnboarding {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return .run { send in
							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
						}
					}
				}
				
				state.featureState = .onBoarding(.init())
				return .none
				
			case .featureAction(.onBoarding(.delegate(.skip))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.delegate(.skip)))))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.delegate(.skip))))))))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.delegate(.skip)))))))))))):
				return .send(.requestCameraStatus)
				
			case .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(.theme(.startButtonTapped)))))))))))))):
				return .run { send in
					try await self.mainQueue.sleep(for: .seconds(0.001))
					await send(.requestCameraStatus)
				}
				
			case .featureAction(.lockScreen(.matchedCode)):
				return .send(.requestCameraStatus)
				
			case .featureAction(.home(.settings(.destination(.presented(.menu(.toggleFaceId(true))))))),
					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.toggleFaceId(isOn: true))))))))))),
					.featureAction(.lockScreen(.checkFaceId)):
				return .send(.biometricAlertPresent(true))
				
			case .featureAction(.home(.settings(.destination(.presented(.menu(.faceId(response:))))))),
					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response:))))))))))),
					.featureAction(.lockScreen(.faceIdResponse)):
				return .run { send in
					try await self.mainQueue.sleep(for: .seconds(10))
					await send(.biometricAlertPresent(false))
				}
				
			case .featureAction:
				return .none
				
			case .startFirstScreen:
				if self.userDefaultsClient.hideSplashScreen {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return .run { send in
							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
						}
					}
				}
				
				return .send(.featureAction(.splash(.startAnimation)))
				
			case .requestCameraStatus:
				return .run { send in
					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
				}
				
			case let .startHome(cameraStatus: status):
				state.isFirstStarted = false
				state.featureState = .home(
					.init(
						tabBars: [.entries, .search, .settings],
						sharedState: SharedState(
							showSplash: !self.userDefaultsClient.hideSplashScreen,
							styleType: self.userDefaultsClient.styleType,
							layoutType: self.userDefaultsClient.layoutType,
							themeType: self.userDefaultsClient.themeType,
							iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light,
							language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
							hasPasscode: (self.userDefaultsClient.passcodeCode ?? "").count > 0,
							cameraStatus: status,
							microphoneStatus: self.avAudioRecorderClient.recordPermission(),
							optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
							faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
						),
						settings: SettingsFeature.State(
							cameraStatus: status,
							microphoneStatus: self.avAudioRecorderClient.recordPermission(),
							userSettings: UserSettings(
								showSplash: !self.userDefaultsClient.hideSplashScreen,
								hasShownOnboarding: true,
								appearance: AppearanceSettings(
									styleType: self.userDefaultsClient.styleType,
									layoutType: self.userDefaultsClient.layoutType,
									themeType: self.userDefaultsClient.themeType,
									iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light
								),
								language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
								passcode: self.userDefaultsClient.passcodeCode ?? "",
								optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
								faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
							)
						)
					)
				)
				return .send(.featureAction(.home(.starting)))
				
			case .process:
				return .none
				
			case .state(.active):
				if state.isFirstStarted {
					return .none
				}
				if state.isBiometricAlertPresent {
					return .none
				}
				if let timeForAskPasscode = self.userDefaultsClient.timeForAskPasscode,
					timeForAskPasscode > self.now {
					return .none
				}
				if let code = self.userDefaultsClient.passcodeCode {
					state.featureState = .lockScreen(.init(code: code))
					return .none
				}
				return .none
				
			case .state(.background):
				if let timeForAskPasscode = Calendar.current.date(
					byAdding: .minute,
					value: self.userDefaultsClient.optionTimeForAskPasscode,
					to: self.now
				) {
					self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode)
					return .none
				}
				self.userDefaultsClient.removeOptionTimeForAskPasscode()
				return .none
				
			case .state:
				return .none
				
			case .shortcuts:
				return .none
				
			case let .biometricAlertPresent(value):
				state.isBiometricAlertPresent = value
				return .none
		}
	}
	
	private func coreData(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		if case .home = state.featureState {
			switch action {
				case .featureAction(.home(.entries(.onAppear))):
					return .run { send in
						for await entries in await self.coreDataClient.subscriber() {
							await send(.featureAction(.home(.entries(.coreDataClientAction(.entries(entries))))))
						}
					}

				case let .featureAction(.home(.entries(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case .featureAction(.home(.settings(.destination(.presented(.export(.processPDF)))))):
					return .run { send in
						await send(
							.featureAction(.home(.settings(.destination(.presented(.export(.generatePDF(self.coreDataClient.fetchAll())))))))
						)
					}
					
				case .featureAction(.home(.settings(.destination(.presented(.export(.previewPDFButtonTapped)))))):
					return .run { send in
						await send(
							.featureAction(.home(.settings(.destination(.presented(.export(.generatePreview(self.coreDataClient.fetchAll())))))))
						)
					}
					
				case let .featureAction(.home(.search(.searching(newText: newText)))):
					return .run { send in
						await send(
							.featureAction(.home(.search(.searchResponse(self.coreDataClient.searchEntries(newText)))))
						)
					}
					
				case .featureAction(.home(.search(.navigateImageSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.images, self.coreDataClient.searchImageEntries())))))
					}
					
				case .featureAction(.home(.search(.navigateVideoSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.videos, self.coreDataClient.searchVideoEntries())))))
					}
					
				case .featureAction(.home(.search(.navigateAudioSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.audios, self.coreDataClient.searchAudioEntries())))))
					}
					
				case let .featureAction(.home(.search(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case let .featureAction(.home(.search(.destination(.presented(.entryDetail(.remove(entry))))))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.featureState,
			let entryDetailState = homeState.entries.entryDetailState {
			switch action {
				case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
					return .run { send in
						await send(
							.featureAction(
								.home(
									.entries(
										.entryDetailAction(
											.entryResponse(
												self.coreDataClient.fetchEntry(entryDetailState.entry)
											)
										)
									)
								)
							)
						)
					}
					
				case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.featureState,
			let addEntryState = homeState.entries.addEntryState {
			switch action {
				case .featureAction(.home(.entries(.destination(.presented(.addEntry(.createDraftEntry)))))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.createDraftEntry))))):
					return .run { _ in
						await self.coreDataClient.createDraft(addEntryState.entry)
					}
					
				case .featureAction(.home(.entries(.destination(.presented(.addEntry(.view(.addButtonTapped))))))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.view(.addButtonTapped)))))):
					let entryText = EntryText(
						id: self.uuid(),
						message: addEntryState.entry.text.message,
						lastUpdated: self.now
					)
					return .run { _ in
						await self.coreDataClient.updateMessage(entryText, addEntryState.entry)
						await self.coreDataClient.publishEntry(addEntryState.entry)
						
					}
				case let .featureAction(.home(.entries(.destination(.presented(.addEntry(.loadImageResponse(entryImage))))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadImageResponse(entryImage)))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.destination(.presented(.addEntry(.loadVideoResponse(entryVideo))))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadVideoResponse(entryVideo)))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.destination(.presented(.addEntry(.loadAudioResponse(entryAudio))))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadAudioResponse(entryAudio)))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.destination(.presented(.addEntry(.removeAttachmentResponse(id))))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeAttachmentResponse(id)))))):
					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
					
				case .featureAction(.home(.entries(.destination(.presented(.addEntry(.removeDraftEntryDismissAlert)))))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeDraftEntryDismissAlert))))):
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
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.layout(.layoutChanged(layout)))))))))):
				self.userDefaultsClient.set(layoutType: layout)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.style(.styleChanged(style)))))))))):
				self.userDefaultsClient.set(styleType: style)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.theme(.themeChanged(theme)))))))))):
				self.userDefaultsClient.set(themeType: theme)
				return .none
			case let .featureAction(.home(.settings(.toggleShowSplash(isOn: isOn)))):
				self.userDefaultsClient.setHideSplashScreen(!isOn)
				return .none
			case .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.delegate(.turnOffPasscode))))))))))),
					.featureAction(.home(.settings(.destination(.presented(.menu(.delegate(.turnOffPasscode))))))):
				self.userDefaultsClient.removePasscode()
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.update(code: code))))))))):
				self.userDefaultsClient.setPasscode(code)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.menu(.faceId(response: faceId))))))),
				let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response: faceId))))))))))):
				self.userDefaultsClient.setFaceIDActivate(faceId)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.menu(.optionTimeForAskPasscode(changed: newOption))))))),
				let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.optionTimeForAskPasscode(changed: newOption))))))))))):
				self.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value)
				return .none
			case .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menuButtonTapped)))))))):
				self.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.language(.updateLanguageTapped(language))))))):
				self.userDefaultsClient.setLanguage(language.rawValue)
				return .none
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.styleChanged(styleChanged))))))))):
				self.userDefaultsClient.set(styleType: styleChanged)
				return .none
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.layoutChanged(layoutChanged)))))))))))):
				self.userDefaultsClient.set(layoutType: layoutChanged)
				return .none
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(
				.theme(.themeChanged(themeChanged))))))))))))))):
				self.userDefaultsClient.set(themeType: themeChanged)
				return .none
			default:
				break
		}
		return .none
	}
}

public struct RootView: View {
	private let store: StoreOf<RootFeature>
	
	public init(
		store: StoreOf<RootFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		AppView(
			store: self.store.scope(
				state: \.featureState,
				action: RootFeature.Action.featureAction
			)
		)
	}
}

extension EntriesFeature.State {
	var addEntryState: AddEntryFeature.State? {
		if case let .addEntry(state) = self.destination {
			return state
		}
		if let state = self.entryDetailState?.addEntryState {
			return state
		}
		return nil
	}
}
