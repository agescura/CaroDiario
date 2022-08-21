//
//  InsertPasscodeView.swift
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

public struct InsertPasscodeState: Equatable {
    public var step: Step = .firstCode
    public var code: String = ""
    public var firstCode: String = ""
    public let maxNumbersCode = 4
    public var codeActivated: Bool = false
    public var codeNotMatched: Bool = false
    
    public var faceIdEnabled: Bool
    public var hasPasscode: Bool {
        self.code == self.firstCode && self.code.count == self.maxNumbersCode
    }
    public var route: Route? {
        didSet {
            if case let .menu(state) = self.route {
                self.faceIdEnabled = state.faceIdEnabled
            }
        }
    }
    
    public enum Route: Equatable {
        case menu(MenuPasscodeState)
    }
    
    public var menuPasscodeState: MenuPasscodeState? {
        get {
            guard case let .menu(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .menu(newValue)
        }
    }
    
    public init(
        faceIdEnabled: Bool,
        route: Route? = nil
    ) {
        self.faceIdEnabled = faceIdEnabled
        self.route = route
    }
    
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

public let insertPasscodeReducer: Reducer<
    InsertPasscodeState,
    InsertPasscodeAction,
    InsertPasscodeEnvironment
> = .combine(
    menuPasscodeReducer
        .optional()
        .pullback(
            state: \InsertPasscodeState.menuPasscodeState,
            action: /InsertPasscodeAction.menuPasscodeAction,
            environment: {
                MenuPasscodeEnvironment(
                    localAuthenticationClient: $0.localAuthenticationClient,
                    mainQueue: $0.mainQueue
                )
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
                        return Effect(value: .navigateMenuPasscode(true))
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
                state.route = value ? .menu(
                    .init(
                        authenticationType: .none,
                        optionTimeForAskPasscode: TimeForAskPasscode.never.value,
                        faceIdEnabled: state.faceIdEnabled
                    )
                ) : nil
                return .none
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
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 8) {
                Spacer()
                VStack(spacing: 32) {
                    Text(viewStore.step.title)
                    HStack {
                        ForEach(0..<viewStore.maxNumbersCode, id: \.self) { iterator in
                            Image(viewStore.code.count > iterator ? .circleFill : .circle)
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
                    route: viewStore.route,
                    case: /InsertPasscodeState.Route.menu,
                    onNavigate: { viewStore.send(.navigateMenuPasscode($0)) },
                    destination: { menuState in
                        MenuPasscodeView(
                            store: self.store.scope(
                                state: { _ in menuState },
                                action: InsertPasscodeAction.menuPasscodeAction
                            )
                        )
                    },
                    label: EmptyView.init
                )
            }
            .padding(16)
            .navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(
                    action: { viewStore.send(.popToRoot) }
                ) {
                    HStack { Image(.chevronRight) }
                }
            )
        }
    }
}
