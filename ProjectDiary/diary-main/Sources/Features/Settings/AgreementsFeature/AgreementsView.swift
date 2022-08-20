//
//  AgreementsView.swift
//  
//
//  Created by Albert Gil Escura on 11/9/21.
//

import ComposableArchitecture
import SwiftUI
import UIApplicationClient
import Views
import Localizables

public enum AgreementType {
    case composableArchitecture
    case pointfree
    case raywenderlich
    
    public var urlString: String {
        switch self {
        case .composableArchitecture:
            return "https://github.com/pointfreeco/swift-composable-architecture"
        case .pointfree:
            return "https://www.pointfree.co/"
        case .raywenderlich:
            return "https://www.raywenderlich.com/"
        }
    }
    
    public var title: String {
        switch self {
        case .composableArchitecture:
            return "The Composable Architecture"
        case .pointfree:
            return "pointfree.co"
        case .raywenderlich:
            return "raywenderlich.com"
        }
    }
}

public struct AgreementsState: Equatable {
    public init() {}
}

public enum AgreementsAction: Equatable {
    case open(AgreementType)
}

public struct AgreementsEnvironment {
    var applicationClient: UIApplicationClient
    
    public init(
        applicationClient: UIApplicationClient
    ) {
        self.applicationClient = applicationClient
    }
}

public let agreementsReducer = Reducer<
    AgreementsState,
    AgreementsAction,
    AgreementsEnvironment
> { state, action, environment in
    switch action {
    case let .open(type):
        guard let url = URL(string: type.urlString) else { return .none }
        return environment.applicationClient.open(url, [:])
            .fireAndForget()
    }
}

public struct AgreementsView: View {
    let store: Store<AgreementsState, AgreementsAction>
    
    public init(
        store: Store<AgreementsState, AgreementsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Section {
                    HStack(spacing: 16) {
                        IconImageView(
                            systemName: "square.and.arrow.up",
                            foregroundColor: .green
                        )
                        Text(AgreementType.composableArchitecture.title)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.adaptiveGray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.open(.composableArchitecture))
                    }
                }
                Section {
                    HStack(spacing: 16) {
                        IconImageView(
                            systemName: "exclamationmark.circle",
                            foregroundColor: .yellow
                        )
                        Text(AgreementType.pointfree.title)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.adaptiveGray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.open(.pointfree))
                    }
                    HStack(spacing: 16) {
                        IconImageView(
                            systemName: "exclamationmark.circle",
                            foregroundColor: .yellow
                        )
                        Text(AgreementType.raywenderlich.title)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.adaptiveGray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.open(.raywenderlich))
                    }
                }
            }
            .navigationBarTitle("Settings.Agreements".localized)
        }
    }
}
