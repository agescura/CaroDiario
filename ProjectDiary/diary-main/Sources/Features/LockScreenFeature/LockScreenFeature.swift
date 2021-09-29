//
//  LockScreenFeature.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 6/7/21.
//

import SwiftUI
import ComposableArchitecture
import SharedStyles
import UserDefaultsClient
import SharedViews
import LocalAuthenticationClient
import SharedLocalizables

public struct LockScreenState: Equatable {
    var code: String
    var codeToMatch: String = ""
    var wrongAttempts: Int = 0
    
    public init(
        code: String,
        codeToMatch: String = ""
    ) {
        self.code = code
        self.codeToMatch = codeToMatch
    }
}

public enum LockScreenAction: Equatable {
    case numberButtonTapped(Int?)
    case matchedCode
    case failedCode
    case reset
    
    case onAppear
    case faceIdResponse(Bool)
}

public struct LockScreenEnvironment {
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

public let lockScreenReducer = Reducer<LockScreenState, LockScreenAction, LockScreenEnvironment> { state, action, environment in
    switch action {
    case let .numberButtonTapped(value):
        if let value = value {
            state.codeToMatch.append("\(value)")
        }
        if state.code == state.codeToMatch {
            return Effect(value: LockScreenAction.matchedCode)
        } else if state.code.count == state.codeToMatch.count {
            return Effect(value: LockScreenAction.failedCode)
        }
        return .none
        
    case .onAppear:
        if environment.userDefaultsClient.isFaceIDActivate {
            return environment.localAuthenticationClient.evaluate("JIJIJAJAJ")
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(LockScreenAction.faceIdResponse)
        } else {
            return .none
        }
        
    case let .faceIdResponse(value):
        if value {
            return Effect(value: LockScreenAction.matchedCode)
                .delay(for: 0.5, scheduler: environment.mainQueue)
                .eraseToEffect()
        }
        return .none
        
    case .matchedCode:
        return .none
        
    case .failedCode:
        state.wrongAttempts = 4
        state.codeToMatch = ""
        return Effect(value: LockScreenAction.reset)
            .delay(for: 0.5, scheduler: environment.mainQueue)
            .eraseToEffect()
        
    case .reset:
        state.wrongAttempts = 0
        return .none
    }
}

public struct LockScreenView: View {
    let store: Store<LockScreenState, LockScreenAction>
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    let data: [LockScreenNumber] = [
        .number(1),
        .number(2),
        .number(3),
        .number(4),
        .number(5),
        .number(6),
        .number(7),
        .number(8),
        .number(9),
        .number(0),
        .emptyLeft,
        .emptyRight
    ]
    
    public init(store: Store<LockScreenState, LockScreenAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Spacer()
                
                Text("LockScreen.Title".localized)
                HStack {
                    ForEach(0..<viewStore.code.count) { iterator in
                        Image(systemName: viewStore.codeToMatch.count > iterator ? "circle.fill" : "circle")
                    }
                }
                .modifier(ShakeGeometryEffect(animatableData: CGFloat(viewStore.wrongAttempts)))
                Spacer()
                LazyVGrid(columns: columns) {
                    ForEach(data) { item in
                        Button(action: {
                            withAnimation(.default) {
                                viewStore.send(.numberButtonTapped(item.value))
                            }
                        }) {
                            LockScreenButton(number: item)
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
//            .onAppear {
//                viewStore.send(.onAppear)
//            }
        }
    }
}

enum LockScreenNumber: Equatable, Identifiable {
    case number(Int)
    case emptyLeft
    case emptyRight
    
    var id: String {
        switch self {
        case let .number(value):
            return "\(value)"
        case .emptyLeft:
            return "emptyLeft"
        case .emptyRight:
            return "emptyRight"
        }
    }
    
    var value: Int? {
        switch self {
        case let .number(value):
            return value
        case .emptyLeft, .emptyRight:
            return nil
        }
    }
}

struct LockScreenButton: View {
    let number: LockScreenNumber
    
    var body: some View {
        switch number {
        case let .number(value):
            Text("\(value)")
                .adaptiveFont(.latoRegular, size: 32)
                .foregroundColor(.adaptiveWhite)
                .padding(32)
                .background(Color.chambray)
                .clipShape(Circle())
        case .emptyLeft, .emptyRight:
            Text("0")
                .adaptiveFont(.latoRegular, size: 32)
                .foregroundColor(.adaptiveWhite)
                .padding(32)
                .background(Color.clear)
        }
    }
}
