//
//  SettingsView.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 29/6/21.
//

import SwiftUI
import ComposableArchitecture
import Combine
import UserDefaultsClient
import SharedStyles
import PasscodeFeature
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import StoreKitClient
import PDFKitClient
import SharedViews
import CoreDataClient
import FileClient
import CloudKitClient

public struct SettingsState: Equatable {
    public var showSplash: Bool
    
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var themeType: ThemeType
    public var iconAppType: IconAppType
    
    public var authenticationType: LocalAuthenticationClient.AuthenticationType = .none
    public var hasPasscode: Bool
    
    public var cameraStatus: AuthorizedVideoStatus
    public var optionTimeForAskPasscode: Int
    
    public var activatePasscodeState: ActivatePasscodeState?
    public var navigateActivatePasscode = false
    
    public var menuPasscodeState: MenuPasscodeState?
    public var navigateMenuPasscode = false
    
    public var cameraSettingsState: CameraSettingsState?
    public var navigateCameraSettings = false
    
    public var appearanceState: AppearanceState?
    public var navigateAppearance = false
    
    public var microphoneStatus: AVAudioSessionClient.AudioRecordPermission = .notDetermined
    
    public var microphoneSettingsState: MicrophoneSettingsState?
    public var navigateMicrophoneSettings = false
    
    public var agreementsState: AgreementsState?
    public var navigateAgreements = false
    
    public var exportState: ExportState?
    public var navigateExport = false
    
    public var aboutState: AboutState?
    public var navigateAbout = false
    
    public init(
        showSplash: Bool = false,
        styleType: StyleType,
        layoutType: LayoutType,
        themeType: ThemeType,
        iconType: IconAppType,
        hasPasscode: Bool,
        cameraStatus: AuthorizedVideoStatus,
        optionTimeForAskPasscode: Int
    ) {
        self.showSplash = showSplash
        self.styleType = styleType
        self.layoutType = layoutType
        self.themeType = themeType
        self.hasPasscode = hasPasscode
        self.iconAppType = iconType
        self.cameraStatus = cameraStatus
        self.optionTimeForAskPasscode = optionTimeForAskPasscode
    }
}

extension AVAudioSessionClient.AudioRecordPermission {
    
    var title: String {
        switch self {
        
        case .authorized:
            return "microphone.authorized".localized
        case .denied:
            return "microphone.denied".localized
        case .notDetermined:
            return "microphone.notDetermined".localized
        }
    }
}

public enum SettingsAction: Equatable {
    case onAppear
    
    case requestAuthorizationCameraResponse(AuthorizedVideoStatus)
    
    case toggleShowSplash(isOn: Bool)
    case biometricResult(LocalAuthenticationClient.AuthenticationType)
    
    case appearanceAction(AppearanceAction)
    case navigateAppearance(Bool)
    
    case activatePasscodeAction(ActivatePasscodeAction)
    case navigateActivatePasscode(Bool)
    
    case menuPasscodeAction(MenuPasscodeAction)
    case navigateMenuPasscode(Bool)
    
    case cameraSettingsAction(CameraSettingsAction)
    case navigateCameraSettings(Bool)
    
    case microphoneSettingsAction(MicrophoneSettingsAction)
    case navigateMicrophoneSettings(Bool)
    
    case agreementsAction(AgreementsAction)
    case navigateAgreements(Bool)
    
    case reviewStoreKit
    
    case exportAction(ExportAction)
    case navigateExport(Bool)
    
    case aboutAction(AboutAction)
    case navigateAbout(Bool)
}

public struct SettingsEnvironment {
    public let coreDataClient: CoreDataClient
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let applicationClient: UIApplicationClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let storeKitClient: StoreKitClient
    public let pdfKitClient: PDFKitClient
    public let cloudKitClient: CloudKitClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
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
        storeKitClient: StoreKitClient,
        pdfKitClient: PDFKitClient,
        cloudKitClient: CloudKitClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        mainRunLoop: AnySchedulerOf<RunLoop>,
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
        self.storeKitClient = storeKitClient
        self.pdfKitClient = pdfKitClient
        self.cloudKitClient = cloudKitClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let settingsReducer: Reducer<SettingsState, SettingsAction, SettingsEnvironment> = .combine(
    
    activatePasscodeReducer
        .optional()
        .pullback(
            state: \SettingsState.activatePasscodeState,
            action: /SettingsAction.activatePasscodeAction,
            environment: { ActivatePasscodeEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    menuPasscodeReducer
        .optional()
        .pullback(
            state: \SettingsState.menuPasscodeState,
            action: /SettingsAction.menuPasscodeAction,
            environment: { MenuPasscodeEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    cameraSettingsReducer
        .optional()
        .pullback(
            state: \SettingsState.cameraSettingsState,
            action: /SettingsAction.cameraSettingsAction,
            environment: { CameraSettingsEnvironment(
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                applicationClient: $0.applicationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    appearanceReducer
        .optional()
        .pullback(
            state: \SettingsState.appearanceState,
            action: /SettingsAction.appearanceAction,
            environment: { AppearanceEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                applicationClient: $0.applicationClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
    microphoneSettingsReducer
        .optional()
        .pullback(
            state: \SettingsState.microphoneSettingsState,
            action: /SettingsAction.microphoneSettingsAction,
            environment: { MicrophoneSettingsEnvironment(
                avAudioSessionClient: $0.avAudioSessionClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                applicationClient: $0.applicationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    agreementsReducer
        .optional()
        .pullback(
            state: \SettingsState.agreementsState,
            action: /SettingsAction.agreementsAction,
            environment: { AgreementsEnvironment(
                applicationClient: $0.applicationClient)
            }
        ),
    
    exportReducer
        .optional()
        .pullback(
            state: \SettingsState.exportState,
            action: /SettingsAction.exportAction,
            environment: { ExportEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                pdfKitClient: $0.pdfKitClient,
                mainRunLoop: $0.mainRunLoop)
            }
        ),
    
    aboutReducer
        .optional()
        .pullback(
            state: \SettingsState.aboutState,
            action: /SettingsAction.aboutAction,
            environment: { AboutEnvironment(
                applicationClient: $0.applicationClient)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case .onAppear:
            state.microphoneStatus = environment.avAudioSessionClient.recordPermission
            return Effect.merge(
                environment.localAuthenticationClient.determineType()
                    .map(SettingsAction.biometricResult),
                environment.avCaptureDeviceClient.authorizationStatus()
                    .map(SettingsAction.requestAuthorizationCameraResponse),
                //environment.cloudKitClient.isCloudAvailable().fireAndForget(),
                environment.cloudKitClient.cloudStatus().fireAndForget()
            )
            
        case let .navigateAppearance(value):
            state.navigateAppearance = value
            state.appearanceState = value ? .init(
                styleType: state.styleType,
                layoutType: state.layoutType,
                themeType: state.themeType,
                iconAppType: state.iconAppType
            ) : nil
            return .none
            
        case .appearanceAction:
            return .none
            
        case let .requestAuthorizationCameraResponse(status):
            state.cameraStatus = status
            return .none
            
        case let .toggleShowSplash(isOn):
            state.showSplash = isOn
            return environment.userDefaultsClient
                .setHideSplashScreen(!isOn)
                .fireAndForget()
            
        case let .biometricResult(result):
            state.authenticationType = result
            return .none
            
        case .activatePasscodeAction(.insertPasscodeAction(.navigateMenuPasscode(true))):
            state.hasPasscode = true
            return .none
            
        case .activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.actionSheetTurnoffTapped))):
            state.hasPasscode = false
            return .merge(
                environment.userDefaultsClient.removePasscode().fireAndForget(),
                Effect(value: SettingsAction.navigateActivatePasscode(false))
            )
            
        case .activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.popToRoot))),
             .activatePasscodeAction(.insertPasscodeAction(.popToRoot)):
            return Effect(value: SettingsAction.navigateActivatePasscode(false))
            
        case .activatePasscodeAction(.insertPasscodeAction(.success)):
            return Effect(value: SettingsAction.navigateActivatePasscode(false))
            
        case .activatePasscodeAction:
            return .none
            
        case let .navigateActivatePasscode(value):
            state.navigateActivatePasscode = value
            state.activatePasscodeState = value ? .init() : nil
            return .none
            
        case .menuPasscodeAction(.actionSheetTurnoffTapped):
            state.hasPasscode = false
            state.navigateMenuPasscode = false
            return environment.userDefaultsClient.removePasscode().fireAndForget()
            
        case .menuPasscodeAction(.popToRoot):
            return Effect(value: SettingsAction.navigateMenuPasscode(false))
            
        case .menuPasscodeAction:
            return .none
            
        case let .navigateMenuPasscode(value):
            state.navigateMenuPasscode = value
            state.menuPasscodeState = value ? .init(authenticationType: state.authenticationType, optionTimeForAskPasscode: state.optionTimeForAskPasscode) : nil
            return .none
            
        case let .cameraSettingsAction(.requestAccessResponse(value)):
            state.cameraStatus = value ? .authorized : .denied
            return .none
            
        case let .microphoneSettingsAction(.requestAccessResponse(value)):
            state.microphoneStatus = value ? .authorized : .denied
            return .none
            
        case .cameraSettingsAction:
            return .none
            
        case let .navigateCameraSettings(value):
            state.navigateCameraSettings = value
            state.cameraSettingsState = value ? .init(.init(cameraStatus: state.cameraStatus)) : nil
            return .none
            
        case .microphoneSettingsAction:
            return .none
            
        case let .navigateMicrophoneSettings(value):
            state.navigateMicrophoneSettings = value
            state.microphoneSettingsState = value ? .init(microphoneStatus: state.microphoneStatus) : nil
            return .none
            
        case let .navigateAgreements(value):
            state.navigateAgreements = value
            state.agreementsState = value ? .init() : nil
            return .none
            
        case .agreementsAction:
            return .none
            
        case .reviewStoreKit:
            return environment.storeKitClient.requestReview()
                .fireAndForget()
            
        case let .navigateExport(value):
            state.navigateExport = value
            state.exportState = value ? .init() : nil
            return .none
            
        case .exportAction:
            return .none
            
        case let .navigateAbout(value):
            state.navigateAbout = value
            state.aboutState = value ? .init() : nil
            return .none
            
        case .aboutAction:
            return .none
        }
    }
)

public struct SettingsView: View {
    let store: Store<SettingsState, SettingsAction>
    
    public init(
        store: Store<SettingsState, SettingsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    
                    Form {
                        Section() {
                            Toggle(
                                isOn: viewStore.binding(
                                    get: \.showSplash,
                                    send: SettingsAction.toggleShowSplash
                                )
                            ) {
                                HStack(spacing: 16) {
                                    IconImageView(
                                        systemName: "book",
                                        foregroundColor: .berryRed
                                    )
                                    
                                    Text("Settings.Splash".localized)
                                        .foregroundColor(.chambray)
                                        .adaptiveFont(.latoRegular, size: 12)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .chambray))
                            
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "rectangle.on.rectangle",
                                    foregroundColor: .orange
                                )
                                
                                Text("Settings.Appearance".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateAppearance(true))
                            }
                        }
                        
                        Section() {
                            
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "faceid",
                                    foregroundColor: .green
                                )
                                
                                Text("Settings.Code".localized(with: [viewStore.authenticationType.rawValue]))
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                Text(viewStore.hasPasscode ? "Settings.On".localized : "Settings.Off".localized)
                                    .foregroundColor(.adaptiveGray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewStore.hasPasscode {
                                    viewStore.send(.navigateMenuPasscode(true))
                                } else {
                                    viewStore.send(.navigateActivatePasscode(true))
                                }
                            }
                        }
                        
                        Section() {
                            
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "camera",
                                    foregroundColor: .pink
                                )
                                
                                Text("Settings.Camera".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                Text(viewStore.cameraStatus.rawValue.localized)
                                    .foregroundColor(.adaptiveGray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateCameraSettings(true))
                            }
                            
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "mic",
                                    foregroundColor: .blue
                                )
                                
                                Text("Settings.Microphone".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                Text(viewStore.microphoneStatus.title.localized)
                                    .foregroundColor(.adaptiveGray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateMicrophoneSettings(true))
                            }
                        }
                        
                        Section() {
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "doc.richtext",
                                    foregroundColor: .adaptiveBlack)
                                
                                Text("Settings.ExportPDF".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateExport(true))
                            }
                        }
                        
                        Section() {
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "number.square",
                                    foregroundColor: .yellow)
                                
                                Text("Settings.ReviewAppStore".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.reviewStoreKit)
                            }
                        }
                        
                        Section() {
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "heart.fill",
                                    foregroundColor: .purple
                                )
                                
                                Text("Settings.Agreements".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateAgreements(true))
                            }
                            
                            HStack(spacing: 16) {
                                IconImageView(
                                    systemName: "message",
                                    foregroundColor: .purple
                                )
                                
                                Text("Settings.About".localized)
                                    .foregroundColor(.chambray)
                                    .adaptiveFont(.latoRegular, size: 12)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.adaptiveGray)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateAbout(true))
                            }
                        }
                    }
                    
                    VStack {
                        NavigationLink(destination: EmptyView()) {
                            EmptyView()
                        }
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.activatePasscodeState,
                                        action: SettingsAction.activatePasscodeAction
                                    ),
                                    then: ActivatePasscodeView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateActivatePasscode,
                                send: SettingsAction.navigateActivatePasscode)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.menuPasscodeState,
                                        action: SettingsAction.menuPasscodeAction
                                    ),
                                    then: MenuPasscodeView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateMenuPasscode,
                                send: SettingsAction.navigateMenuPasscode)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.cameraSettingsState,
                                        action: SettingsAction.cameraSettingsAction
                                    ),
                                    then: CameraSettingsView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateCameraSettings,
                                send: SettingsAction.navigateCameraSettings)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.appearanceState,
                                        action: SettingsAction.appearanceAction
                                    ),
                                    then: AppearanceView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateAppearance,
                                send: SettingsAction.navigateAppearance)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.microphoneSettingsState,
                                        action: SettingsAction.microphoneSettingsAction
                                    ),
                                    then: MicrophoneSettingsView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateMicrophoneSettings,
                                send: SettingsAction.navigateMicrophoneSettings)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.agreementsState,
                                        action: SettingsAction.agreementsAction
                                    ),
                                    then: AgreementsView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateAgreements,
                                send: SettingsAction.navigateAgreements)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.exportState,
                                        action: SettingsAction.exportAction
                                    ),
                                    then: ExportView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateExport,
                                send: SettingsAction.navigateExport)
                        )
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.aboutState,
                                        action: SettingsAction.aboutAction
                                    ),
                                    then: AboutView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateAbout,
                                send: SettingsAction.navigateAbout)
                        )
                        
                        NavigationLink(destination: EmptyView()) {
                            EmptyView()
                        }
                    }
                    .frame(height: 0)
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
