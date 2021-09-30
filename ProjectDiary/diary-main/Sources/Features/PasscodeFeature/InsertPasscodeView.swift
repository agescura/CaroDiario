//
//  InsertPasscodeView.swift
//  
//
//  Created by Albert Gil Escura on 18/7/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import SharedViews
import LocalAuthenticationClient

public struct InsertPasscodeState: Equatable {
    public var step: Step = .firstCode
    public var code: String = ""
    public var firstCode: String = ""
    public let maxNumbersCode = 4
    public var codeActivated: Bool = false
    public var codeNotMatched: Bool = false
    
    public var menuPasscodeState: MenuPasscodeState?
    public var navigateMenuPasscode: Bool = false
    
    public init() {}
    
    public enum Step: Int {
        case firstCode
        case secondCode
        
        var title: String {
            switch self {
            case .firstCode:
                return "Passcode.Insert".localized
            case .secondCode:
                return "Passcode.Reinsert".localized
            }
        }
    }
}

public enum InsertPasscodeAction: Equatable {
    case update(code: String)
    case success
    case popToRoot
    
    case menuPasscodeAction(MenuPasscodeAction)
    case navigateMenuPasscode(Bool)
}

public struct InsertPasscodeEnvironment {
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

public let insertPasscodeReducer: Reducer<InsertPasscodeState, InsertPasscodeAction, InsertPasscodeEnvironment> = .combine(

    menuPasscodeReducer
        .optional()
        .pullback(
            state: \InsertPasscodeState.menuPasscodeState,
            action: /InsertPasscodeAction.menuPasscodeAction,
            environment: { MenuPasscodeEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case let .update(code: code):
            state.code = code
            if state.step == .firstCode,
               state.code.count == state.maxNumbersCode {
                state.codeNotMatched = false
                state.firstCode = state.code
                state.step = .secondCode
                state.code = ""
            }
            if state.step == .secondCode,
               state.code.count == state.maxNumbersCode {
                if state.code == state.firstCode {
                    return .merge(
                        environment.userDefaultsClient.setPasscode(state.code).fireAndForget(),
                        Effect(value: InsertPasscodeAction.navigateMenuPasscode(true))
                    )
                } else {
                    state.step = .firstCode
                    state.code = ""
                    state.firstCode = ""
                    state.codeNotMatched = true
                }
            }
            return .none
            
        case .success:
            return .none
            
        case .popToRoot:
            return .none
            
        case .menuPasscodeAction:
            return .none
            
        case let .navigateMenuPasscode(value):
            state.navigateMenuPasscode = value
            state.menuPasscodeState = value ? .init(authenticationType: .none, optionTimeForAskPasscode: -2) : nil
            return environment.userDefaultsClient.setOptionTimeForAskPasscode(-2).fireAndForget()
        }
    }
    
)

public struct InsertPasscodeView: View {
    let store: Store<InsertPasscodeState, InsertPasscodeAction>
    
    public init(
        store: Store<InsertPasscodeState, InsertPasscodeAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8) {
                Spacer()
                VStack(spacing: 32) {
                    Text(viewStore.step.title)
                    HStack {
                        ForEach(0..<viewStore.maxNumbersCode) { iterator in
                            Image(systemName: viewStore.code.count > iterator ? "circle.fill" : "circle")
                        }
                    }
                    if viewStore.codeNotMatched {
                        Text("Passcode.Different".localized)
                            .foregroundColor(.berryRed)
                    }
                    Spacer()
                }
                CustomTextField(
                    text: viewStore.binding(
                        get: \.code,
                        send: InsertPasscodeAction.update
                    ),
                    isFirstResponder: true
                )
                .frame(width: 300, height: 50)
                .opacity(0.0)
                
                Spacer()
                SecondaryButtonView(
                    label: { Text("Passcode.Dismiss".localized) }
                ) {
                    viewStore.send(.popToRoot)
                }
                
                NavigationLink(
                    "",
                    destination:
                        IfLetStore(
                            store.scope(
                                state: \.menuPasscodeState,
                                action: InsertPasscodeAction.menuPasscodeAction
                            ),
                            then: MenuPasscodeView.init(store:)
                        ),
                    isActive: viewStore.binding(
                        get: \.navigateMenuPasscode,
                        send: InsertPasscodeAction.navigateMenuPasscode)
                )
            }
            .padding(16)
            .navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                viewStore.send(.popToRoot)
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                }
            })
        }
    }
}
