//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 19/3/22.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import UserDefaultsClient

public struct LanguageState: Equatable {
    public var language: Localizable
}

public enum LanguageAction: Equatable {
    case updateLanguageTapped(Localizable)
}

public struct LanguageEnvironment {
    let userDefaults: UserDefaultsClient
}

public let languageReducer = Reducer<LanguageState, LanguageAction, LanguageEnvironment> { state, action, environment in
    switch action {
    case let .updateLanguageTapped(language):
        state.language = language
        return environment.userDefaults.setLanguage(language.rawValue)
            .fireAndForget()
    }
}

public struct LanguageView: View {
    let store: Store<LanguageState, LanguageAction>
    
    public init(
        store: Store<LanguageState, LanguageAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEach(Localizable.allCases) { language in
                    HStack {
                        Text(language.localizable.localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                        Spacer()
                        if viewStore.language == language {
                            Image(systemName: "checkmark")
                                .foregroundColor(.adaptiveGray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.updateLanguageTapped(language))
                    }
                    
                }
            }
            .navigationBarTitle("Settings.Language".localized)
        }
    }
}
