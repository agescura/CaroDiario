//
//  ActivatePasscodeView.swift
//  
//
//  Created by Albert Gil Escura on 18/7/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import SharedViews
import LocalAuthenticationClient

public struct ActivatePasscodeState: Equatable {
    public var insertPasscodeState: InsertPasscodeState?
    public var navigateInsertPasscode: Bool = false
    
    public init() {}
}

public enum ActivatePasscodeAction: Equatable {
    case insertPasscodeAction(InsertPasscodeAction)
    case navigateInsertPasscode(Bool)
}

public struct ActivatePasscodeEnvironment {
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

public let activatePasscodeReducer: Reducer<ActivatePasscodeState, ActivatePasscodeAction, ActivatePasscodeEnvironment> = .combine(
    
    insertPasscodeReducer
        .optional()
        .pullback(
            state: \ActivatePasscodeState.insertPasscodeState,
            action: /ActivatePasscodeAction.insertPasscodeAction,
            environment: { InsertPasscodeEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    .init { state, action, environment in
        switch action {
            
        case .insertPasscodeAction:
            return .none
            
        case let .navigateInsertPasscode(value):
            state.navigateInsertPasscode = value
            state.insertPasscodeState = value ? .init() : nil
            return .none
        }
    }
)

public struct ActivatePasscodeView: View {
    let store: Store<ActivatePasscodeState, ActivatePasscodeAction>
    
    public init(
        store: Store<ActivatePasscodeState, ActivatePasscodeAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text("Passcode.Title".localized)
                    .font(.title)
                Text("Passcode.Activate.Message".localized)
                    .font(.caption)
                Spacer()
                
                PrimaryButtonView(
                    label: { Text("Passcode.Activate.Title".localized) }
                ) {
                    viewStore.send(.navigateInsertPasscode(true))
                }
                
                NavigationLink(
                    "",
                    destination:
                        IfLetStore(
                            store.scope(
                                state: \.insertPasscodeState,
                                action: ActivatePasscodeAction.insertPasscodeAction
                            ),
                            then: InsertPasscodeView.init(store:)
                        ),
                    isActive: viewStore.binding(
                        get: \.navigateInsertPasscode,
                        send: ActivatePasscodeAction.navigateInsertPasscode)
                )
            }
            .padding(.horizontal, 16)
        }
    }
}
