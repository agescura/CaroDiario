//
//  MenuPasscodeView.swift
//  
//
//  Created by Albert Gil Escura on 19/7/21.
//

import SwiftUI
import ComposableArchitecture
import SharedViews
import UserDefaultsClient
import SharedLocalizables
import LocalAuthenticationClient

public struct MenuPasscodeState: Equatable {
    public var authenticationType: LocalAuthenticationClient.AuthenticationType
    
    var actionSheet: ConfirmationDialogState<MenuPasscodeAction>?
    public var faceIdEnabled: Bool = false
    
    public var optionTimeForAskPasscode: TimeForAskPasscode
    public let listTimesForAskPasscode: [TimeForAskPasscode] = [.never, .always, .after(minutes: 1), .after(minutes: 5), .after(minutes: 30), .after(minutes: 60)]
    
    public init(
        authenticationType: LocalAuthenticationClient.AuthenticationType,
        optionTimeForAskPasscode: Int
    ) {
        self.authenticationType = authenticationType
        
        if optionTimeForAskPasscode == -2 {
            self.optionTimeForAskPasscode = .never
        } else if optionTimeForAskPasscode == -1 {
            self.optionTimeForAskPasscode = .always
        } else {
            self.optionTimeForAskPasscode = .after(minutes: optionTimeForAskPasscode)
        }
    }
    
    public enum TimeForAskPasscode: Equatable, Identifiable, Hashable {
        case always
        case never
        case after(minutes: Int)
        
        public var rawValue: String {
            switch self {
            case .always:
                return "Passcode.Always".localized
            case .never:
                return "Passcode.Disabled".localized
            case .after(minutes: let minutes):
                return "\("Passcode.IfAway".localized)\(minutes) min"
            }
        }
        
        public var id: String {
            rawValue
        }
    }
}

public enum MenuPasscodeAction: Equatable {
    case onAppear
    
    case popToRoot
    
    case actionSheetButtonTapped
    case actionSheetCancelTapped
    case actionSheetTurnoffTapped
    
    case toggleFaceId(isOn: Bool)
    case faceId(response: Bool)
    case optionTimeForAskPasscode(changed: MenuPasscodeState.TimeForAskPasscode)
}

public struct MenuPasscodeEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        userDefaultsClient: UserDefaultsClient,
        localAuthenticationClient: LocalAuthenticationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.userDefaultsClient = userDefaultsClient
        self.localAuthenticationClient = localAuthenticationClient
        self.mainQueue = mainQueue
    }
}

public let menuPasscodeReducer = Reducer<MenuPasscodeState, MenuPasscodeAction, MenuPasscodeEnvironment> { state, action, environment in
    switch action {
    
    case .onAppear:
        state.faceIdEnabled = environment.userDefaultsClient.isFaceIDActivate
        return .none
        
    case .popToRoot:
        return .none
        
    case .actionSheetButtonTapped:
        state.actionSheet = .init(
            title: .init("Passcode.Turnoff.Message".localized(with: [state.authenticationType.rawValue])),
            buttons: [
                .cancel(.init("Cancel".localized), action: .send(.actionSheetCancelTapped)),
                .default(.init("Passcode.Turnoff".localized), action: .send(.actionSheetTurnoffTapped))
            ]
        )
        return .none
        
    case .actionSheetCancelTapped:
        state.actionSheet = nil
        return .none
        
    case .actionSheetTurnoffTapped:
        return .none
        
    case let .toggleFaceId(isOn: value):
        if !value {
            state.faceIdEnabled = value
            return environment.userDefaultsClient.setFaceIDActivate(value)
                .fireAndForget()
        }
        return environment.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [state.authenticationType.rawValue]))
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(MenuPasscodeAction.faceId(response:))
        
    case let .faceId(response: response):
        state.faceIdEnabled = response
        return environment.userDefaultsClient.setFaceIDActivate(response)
            .fireAndForget()
        
    case let .optionTimeForAskPasscode(changed: newValue):
        state.optionTimeForAskPasscode = newValue
        switch newValue {
        case .always:
            return environment.userDefaultsClient.setOptionTimeForAskPasscode(-1)
                .fireAndForget()
        case .never:
            return environment.userDefaultsClient.setOptionTimeForAskPasscode(-2)
                .fireAndForget()
        case .after(minutes: let minutes):
            return environment.userDefaultsClient.setOptionTimeForAskPasscode(minutes)
                .fireAndForget()
        }
    }
}

public struct MenuPasscodeView: View {
    let store: Store<MenuPasscodeState, MenuPasscodeAction>
    
    public init(
        store: Store<MenuPasscodeState, MenuPasscodeAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section(
                    footer: Text("Passcode.Activate.Message".localized)
                ) {
                    Button(action: {
                        viewStore.send(.actionSheetButtonTapped)
                    }) {
                        Text("Passcode.Turnoff".localized)
                            .foregroundColor(.chambray)
                    }
                    .confirmationDialog(
                      store.scope(state: \.actionSheet),
                      dismiss: .actionSheetCancelTapped
                    )
                }
                
                Section(header: Text(""), footer: Text("")) {
                    Toggle(
                        isOn: viewStore.binding(
                            get: \.faceIdEnabled,
                            send: MenuPasscodeAction.toggleFaceId
                        )
                    ) {
                        Text("Passcode.UnlockFaceId".localized(with: [viewStore.authenticationType.rawValue]))
                            .foregroundColor(.chambray)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .chambray))
                    
                    Picker("",  selection: viewStore.binding(
                        get: \.optionTimeForAskPasscode,
                        send: MenuPasscodeAction.optionTimeForAskPasscode
                    )) {
                        ForEach(viewStore.listTimesForAskPasscode, id: \.self) { type in
                            Text(type.rawValue)
                                .adaptiveFont(.latoRegular, size: 12)
                        }
                    }
                    .overlay(HStack(spacing: 16) {
                        Text("Passcode.Autolock".localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                        Spacer()
                    })
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationBarItems(leading: Button(action: {
                viewStore.send(.popToRoot)
            }) {
                Image(systemName: "chevron.left")
            })
        }
        .navigationBarTitle("Passcode.Title".localized)
        .navigationBarBackButtonHidden(true)
    }
}
