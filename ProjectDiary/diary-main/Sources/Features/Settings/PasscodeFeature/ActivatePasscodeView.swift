//
//  ActivatePasscodeView.swift
//  
//
//  Created by Albert Gil Escura on 18/7/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import Views
import LocalAuthenticationClient
import SwiftUIHelper

public struct ActivatePasscodeState: Equatable {
    public var faceIdEnabled: Bool
    public var hasPasscode: Bool
    
    public var route: Route? {
        didSet {
            if case let .insert(state) = self.route {
                self.faceIdEnabled = state.faceIdEnabled
                self.hasPasscode = state.hasPasscode
            }
        }
    }
    
    public enum Route: Equatable {
        case insert(InsertPasscodeState)
    }
    
    public var insertPasscodeState: InsertPasscodeState? {
        get {
            guard case let .insert(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .insert(newValue)
        }
    }
    
    public init(
        faceIdEnabled: Bool,
        hasPasscode: Bool
    ) {
        self.faceIdEnabled = faceIdEnabled
        self.hasPasscode = hasPasscode
    }
}

public enum ActivatePasscodeAction: Equatable {
    case insertPasscodeAction(InsertPasscodeAction)
    case navigateInsertPasscode(Bool)
}

public struct ActivatePasscodeEnvironment {
    public let localAuthenticationClient: LocalAuthenticationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        localAuthenticationClient: LocalAuthenticationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.localAuthenticationClient = localAuthenticationClient
        self.mainQueue = mainQueue
    }
}

public let activatePasscodeReducer: Reducer<
    ActivatePasscodeState,
    ActivatePasscodeAction,
    ActivatePasscodeEnvironment
> = .combine(
    insertPasscodeReducer
        .optional()
        .pullback(
            state: \ActivatePasscodeState.insertPasscodeState,
            action: /ActivatePasscodeAction.insertPasscodeAction,
            environment: {
                InsertPasscodeEnvironment(
                    localAuthenticationClient: $0.localAuthenticationClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    
        .init { state, action, environment in
        switch action {
            
        case .insertPasscodeAction:
            return .none
            
        case let .navigateInsertPasscode(value):
            state.route = value ? .insert(
                .init(faceIdEnabled: state.faceIdEnabled)
            ) : nil
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
        WithViewStore(self.store) { viewStore in
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
                    route: viewStore.route,
                    case: /ActivatePasscodeState.Route.insert,
                    onNavigate: { viewStore.send(.navigateInsertPasscode($0)) },
                    destination: { insertState in
                        InsertPasscodeView(
                            store: self.store.scope(
                                state: { _ in insertState },
                                action: ActivatePasscodeAction.insertPasscodeAction
                            )
                        )
                    },
                    label: EmptyView.init
                )
            }
            .padding(.horizontal, 16)
        }
    }
}
