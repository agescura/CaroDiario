//
//  LockScreenFeature.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 6/7/21.
//

import SwiftUI
import ComposableArchitecture
import Styles
import UserDefaultsClient
import Views
import LocalAuthenticationClient
import Localizables
import Models

public struct LockScreenState: Equatable {
    var code: String
    var codeToMatch: String = ""
    var wrongAttempts: Int = 0
    
    public var authenticationType: LocalAuthenticationType = .none
    public var buttons: [LockScreenNumber] = []
    
    public init(
        code: String,
        codeToMatch: String = ""
    ) {
        self.code = code
        self.codeToMatch = codeToMatch
    }
}

public enum LockScreenAction: Equatable {
    case numberButtonTapped(LockScreenNumber)
    case matchedCode
    case failedCode
    case reset
    
    case onAppear
    case checkFaceId
    case determine(LocalAuthenticationType)
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
    case let .numberButtonTapped(item):
        if item == .biometric(.touchId) || item == .biometric(.faceId) {
            return Effect(value: .checkFaceId)
        }
        if let value = item.value {
            state.codeToMatch.append("\(value)")
        }
        if state.code == state.codeToMatch {
            return Effect(value: LockScreenAction.matchedCode)
        } else if state.code.count == state.codeToMatch.count {
            return Effect(value: LockScreenAction.failedCode)
        }
        return .none
        
    case .onAppear:
        return .merge(
            Effect(value: .checkFaceId),
            environment.localAuthenticationClient.determineType()
                .map(LockScreenAction.determine)
        )
        
    case let .determine(type):
        state.authenticationType = type
        
        let leftButton: LockScreenNumber = type == .none || !environment.userDefaultsClient.isFaceIDActivate ? .emptyLeft : .biometric(type)
        state.buttons = [
            .number(1),
            .number(2),
            .number(3),
            .number(4),
            .number(5),
            .number(6),
            .number(7),
            .number(8),
            .number(9),
            leftButton,
            .number(0),
            .emptyRight
        ]
        return .none
        
    case .checkFaceId:
        
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
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(
        store: Store<LockScreenState, LockScreenAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 16) {
                Spacer()
                Text("LockScreen.Title".localized)
                HStack {
                    ForEach(0..<viewStore.code.count, id: \.self) { iterator in
                        Image(systemName: viewStore.codeToMatch.count > iterator ? "circle.fill" : "circle")
                    }
                }
                .modifier(ShakeGeometryEffect(animatableData: CGFloat(viewStore.wrongAttempts)))
                Spacer()
                LazyVGrid(columns: columns) {
                    ForEach(viewStore.buttons) { item in
                        Button(
                            action: {
                                viewStore.send(.numberButtonTapped(item), animation: .default)
                            },
                            label: {
                                LockScreenButton(number: item)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

public enum LockScreenNumber: Equatable, Identifiable {
    case number(Int)
    case emptyLeft
    case emptyRight
    case biometric(LocalAuthenticationType)
    
    public var id: String {
        switch self {
        case let .number(value):
            return "\(value)"
        case .emptyLeft:
            return "emptyLeft"
        case .emptyRight:
            return "emptyRight"
        case .biometric(.touchId):
            return "touchid"
        case .biometric(.faceId):
            return "faceid"
        case .biometric:
            return "none"
        }
    }
    
    public var value: Int? {
        switch self {
        case let .number(value):
            return value
        case .emptyLeft, .emptyRight, .biometric:
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
        case .biometric:
            Image(systemName: number.id)
                .adaptiveFont(.latoRegular, size: 32)
                .foregroundColor(.adaptiveWhite)
                .padding(20)
                .background(Color.chambray)
                .clipShape(Circle())
        }
    }
}
