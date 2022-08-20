//
//  AppView.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 26/6/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import CoreDataClient
import FileClient
import AppFeature
import LocalAuthenticationClient
import HomeFeature
import Styles
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient

public struct RootState: Equatable {
    public var appDelegate: AppDelegateState
    public var featureState: AppState
    
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
        featureState: AppState
    ) {
        self.appDelegate = appDelegate
        self.featureState = featureState
    }
}

public enum RootAction: Equatable {
    case appDelegate(AppDelegateAction)
    case featureAction(AppAction)
    
    case setUserInterfaceStyle
    case startFirstScreen

    case requestCameraStatus
    case startHome(cameraStatus: AuthorizedVideoStatus)
    
    case process(URL)
    case state(RootState.State)
    case shortcuts
    
    case biometricAlertPresent(Bool)
}

public struct RootEnvironment {
    public let coreDataClient: CoreDataClient
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let applicationClient: UIApplicationClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let storeKitClient: StoreKitClient
    public let pdfKitClient: PDFKitClient
    public let avAssetClient: AVAssetClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        coreDataClient: CoreDataClient,
        fileClient: FileClient,
        userDefaultsClient: UserDefaultsClient,
        localAuthenticationClient: LocalAuthenticationClient,
        applicationClient: UIApplicationClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        storeKitClient: StoreKitClient,
        pdfKitClient: PDFKitClient,
        avAssetClient: AVAssetClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.coreDataClient = coreDataClient
        self.fileClient = fileClient
        self.userDefaultsClient = userDefaultsClient
        self.localAuthenticationClient = localAuthenticationClient
        self.applicationClient = applicationClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.storeKitClient = storeKitClient
        self.pdfKitClient = pdfKitClient
        self.avAssetClient = avAssetClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.date = date
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let rootReducer: Reducer<RootState, RootAction, RootEnvironment> = .combine(
    appDelegateReducer
        .pullback(
            state: \.appDelegate,
            action: /RootAction.appDelegate,
            environment: { _ in () }
        ),
    appReducer
        .pullback(
            state: \RootState.featureState,
            action: /RootAction.featureAction,
            environment: {
                AppEnvironment(
                    fileClient: $0.fileClient,
                    userDefaultsClient: $0.userDefaultsClient,
                    localAuthenticationClient: $0.localAuthenticationClient,
                    applicationClient: $0.applicationClient,
                    avCaptureDeviceClient: $0.avCaptureDeviceClient,
                    feedbackGeneratorClient: $0.feedbackGeneratorClient,
                    avAudioSessionClient: $0.avAudioSessionClient,
                    avAudioPlayerClient: $0.avAudioPlayerClient,
                    avAudioRecorderClient: $0.avAudioRecorderClient,
                    storeKitClient: $0.storeKitClient,
                    pdfKitClient: $0.pdfKitClient,
                    avAssetClient: $0.avAssetClient,
                    mainQueue: $0.mainQueue,
                    backgroundQueue: $0.backgroundQueue,
                    date: $0.date,
                    uuid: $0.uuid,
                    setUserInterfaceStyle: $0.setUserInterfaceStyle
                )
            }
        ),
    
    .init() { state, action, environment in
        switch action {

        case .appDelegate(.didFinishLaunching):
            return Effect(value: .setUserInterfaceStyle)
            
        case .setUserInterfaceStyle:
            return .merge(
                environment.setUserInterfaceStyle(environment.userDefaultsClient.themeType.userInterfaceStyle)
                    .fireAndForget(),
                Effect(value: .startFirstScreen)
            )
            
        case .featureAction(.splash(.finishAnimation)):
            if environment.userDefaultsClient.hasShownFirstLaunchOnboarding {
                if let code = environment.userDefaultsClient.passcodeCode {
                    state.featureState = .lockScreen(.init(code: code))
                    return .none
                } else {
                    return environment.avCaptureDeviceClient.authorizationStatus()
                        .map(RootAction.startHome)
                }
            }
            
            state.featureState = .onBoarding(.init())
            return .none
            
        case .featureAction(.onBoarding(.skipAlertAction)),
             .featureAction(.onBoarding(.privacyOnBoardingAction(.skipAlertAction))):
            return Effect(value: RootAction.requestCameraStatus)
            
        case .featureAction(.onBoarding(.privacyOnBoardingAction(.styleOnBoardingAction(.layoutOnBoardingAction(.themeOnBoardingAction(.startButtonTapped)))))):
            return Effect(value: RootAction.requestCameraStatus)
                .delay(for: 0.001, scheduler: environment.mainQueue)
                .eraseToEffect()
            
        case .featureAction(.lockScreen(.matchedCode)):
            return Effect(value: RootAction.requestCameraStatus)

        case .featureAction(.home(.settings(.menuPasscodeAction(.toggleFaceId(true))))),
                .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.toggleFaceId(isOn: true))))))),
                .featureAction(.lockScreen(.checkFaceId)):
            return Effect(value: .biometricAlertPresent(true))
            
        case .featureAction(.home(.settings(.menuPasscodeAction(.faceId(response:))))),
                .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.faceId(response:))))))),
                .featureAction(.lockScreen(.faceIdResponse)):
            return Effect(value: .biometricAlertPresent(false))
                .delay(for: 10, scheduler: environment.mainQueue)
                .eraseToEffect()
            
        case .featureAction:
            return .none
            
        case .startFirstScreen:
            if environment.userDefaultsClient.hideSplashScreen {
                if let code = environment.userDefaultsClient.passcodeCode {
                    state.featureState = .lockScreen(.init(code: code))
                    return .none
                } else {
                    return environment.avCaptureDeviceClient.authorizationStatus()
                        .map(RootAction.startHome)
                }
            }
            
            return Effect(value: RootAction.featureAction(.splash(.startAnimation)))
            
        case .requestCameraStatus:
            return environment.avCaptureDeviceClient.authorizationStatus()
                .map(RootAction.startHome)
            
        case let .startHome(cameraStatus: status):
            state.isFirstStarted = false
            state.featureState = .home(
                .init(
                    tabBars: [.entries, .search, .settings],
                    entriesState: .init(entries: []),
                    searchState: .init(searchText: "", entries: []),
                    settings: .init(
                        showSplash: !environment.userDefaultsClient.hideSplashScreen,
                        styleType: environment.userDefaultsClient.styleType,
                        layoutType: environment.userDefaultsClient.layoutType,
                        themeType: environment.userDefaultsClient.themeType,
                        iconType: environment.applicationClient.alternateIconName != nil ? .dark : .light ,
                        hasPasscode: (environment.userDefaultsClient.passcodeCode ?? "").count > 0,
                        cameraStatus: status,
                        optionTimeForAskPasscode: environment.userDefaultsClient.optionTimeForAskPasscode
                    )
                )
            )
            return Effect(value: RootAction.featureAction(.home(.starting)))
            
        case let .process(url):
            return .none
            
        case .state(.active):
            if state.isFirstStarted {
                return .none
            }
            if state.isBiometricAlertPresent {
                return .none
            }
            if let timeForAskPasscode = environment.userDefaultsClient.timeForAskPasscode,
               timeForAskPasscode > environment.date() {
                return .none
            }
            if let code = environment.userDefaultsClient.passcodeCode {
                state.featureState = .lockScreen(.init(code: code))
                return .none
            }
            return .none
            
        case .state(.background):
            if let timeForAskPasscode = Calendar.current.date(
                byAdding: .minute,
                value: environment.userDefaultsClient.optionTimeForAskPasscode,
                to: environment.date()) {
                return environment.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode).fireAndForget()
            }
            return environment.userDefaultsClient.removeOptionTimeForAskPasscode().fireAndForget()
            
        case .state:
            return .none
            
        case .shortcuts:
            return .none
            
        case let .biometricAlertPresent(value):
            state.isBiometricAlertPresent = value
            return .none
        }
    }
)
.coreData()
.userDefaults()

public struct RootView: View {
    let store: Store<RootState, RootAction>
    
    public init(
        store: Store<RootState, RootAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        AppView(
            store: store.scope(
                state: \.featureState,
                action: RootAction.featureAction
            )
        )
    }
}

import Models

extension Reducer where State == RootState, Action == RootAction, Environment == RootEnvironment {
    public func userDefaults() -> Reducer {
        return .init { state, action, environment in
            let effects = self.run(&state, action, environment)
            
            switch action {
            case let .featureAction(.home(.settings(.appearanceAction(.layoutAction(.layoutChanged(layout)))))):
                return .merge(
                    environment.userDefaultsClient.set(layoutType: layout)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearanceAction(.styleAction(.styleChanged(style)))))):
                return .merge(
                    environment.userDefaultsClient.set(styleType: style)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearanceAction(.themeAction(.themeChanged(theme)))))):
                return .merge(
                    environment.userDefaultsClient.set(themeType: theme)
                        .fireAndForget(),
                    effects
                )
            default:
                return effects
            }
        }
    }
}

extension Reducer where State == RootState, Action == RootAction, Environment == RootEnvironment {
    struct CoreDataId: Hashable {}
    
    public func coreData() -> Reducer {
        return .init { state, action, environment in
            let effects = self.run(&state, action, environment)
            
            if case .home = state.featureState {
                switch action {
                case .featureAction(.home(.entries(.onAppear))):
                    return .merge(
                        environment.coreDataClient.create(CoreDataId())
                            .receive(on: environment.mainQueue)
                            .eraseToEffect()
                            .map({ RootAction.featureAction(.home(.entries(.coreDataClientAction($0)))) }),
                        effects
                    )
                case let .featureAction(.home(.entries(.remove(entry)))):
                    return environment.coreDataClient.removeEntry(entry.id)
                        .fireAndForget()
                    
                case .featureAction(.home(.settings(.exportAction(.processPDF)))):
                    return .merge(
                        environment.coreDataClient.fetchAll()
                            .map({ RootAction.featureAction(.home(.settings(.exportAction(.generatePDF($0))))) }),
                        effects
                    )
                    
                case .featureAction(.home(.settings(.exportAction(.previewPDF)))):
                    return .merge(
                        environment.coreDataClient.fetchAll()
                            .map({ RootAction.featureAction(.home(.settings(.exportAction(.generatePreview($0))))) }),
                        effects
                    )
                    
                case let .featureAction(.home(.search(.searching(newText: newText)))):
                    return .merge(
                        environment.coreDataClient.searchEntries(newText)
                            .map({ RootAction.featureAction(.home(.search(.searchResponse($0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateImageSearch))):
                    return .merge(
                        environment.coreDataClient.searchImageEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.images, $0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateVideoSearch))):
                    return .merge(
                        environment.coreDataClient.searchVideoEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.videos, $0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateAudioSearch))):
                    return .merge(
                        environment.coreDataClient.searchAudioEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.audios, $0)))) }),
                        effects
                    )
                case let .featureAction(.home(.search(.remove(entry)))):
                    return .merge(
                        environment.coreDataClient.removeEntry(entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.search(.entryDetailAction(.remove(entry))))):
                    return .merge(
                        environment.coreDataClient.removeEntry(entry.id)
                            .fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            
            if case let .home(homeState) = state.featureState,
               let entryDetailState = homeState.entriesState.entryDetailState {
                switch action {
                case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
                    return .merge(
                        environment.coreDataClient.fetchEntry(entryDetailState.entry)
                            .map({ RootAction.featureAction(.home(.entries(.entryDetailAction(.entryResponse($0))))) }),
                        effects
                    )
                case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
                    return .merge(
                        environment.coreDataClient.removeAttachmentEntry(id).fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            
            if case let .home(homeState) = state.featureState,
               let addEntryState = homeState.entriesState.addEntryState ?? homeState.entriesState.entryDetailState?.addEntryState {
                switch action {
                case .featureAction(.home(.entries(.addEntryAction(.createDraftEntry)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.createDraftEntry))))):
                    return .merge(
                        environment.coreDataClient.createDraft(addEntryState.entry)
                            .fireAndForget(),
                        effects
                    )
                case .featureAction(.home(.entries(.addEntryAction(.addButtonTapped)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.addButtonTapped))))):
                    let entryText = EntryText(
                        id: environment.uuid(),
                        message: addEntryState.text,
                        lastUpdated: environment.date()
                    )
                    return .merge(
                        environment.coreDataClient.updateMessage(entryText, addEntryState.entry)
                            .fireAndForget(),
                        environment.coreDataClient.publishEntry(addEntryState.entry)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadImageResponse(entryImage)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadVideoResponse(entryVideo)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadAudioResponse(entryAudio)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeAttachmentResponse(id)))))):
                    return .merge(
                        environment.coreDataClient.removeAttachmentEntry(id)
                            .fireAndForget(),
                        effects
                    )
                case .featureAction(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeDraftEntryDismissAlert))))):
                    return .merge(
                        environment.coreDataClient.removeEntry(addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            return effects
        }
    }
}
