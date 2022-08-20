//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 19/3/22.
//

import SwiftUI
import ComposableArchitecture
import Models
import UserDefaultsClient
import Models
import Localizables

public struct LanguageState: Equatable {
    public var language: Localizable
    
    public init(
        language: Localizable
    ) {
        self.language = language
    }
}

public enum LanguageAction: Equatable {
    case updateLanguageTapped(Localizable)
}

public struct LanguageEnvironment {
    let userDefaults: UserDefaultsClient
    
    public init(
        userDefaults: UserDefaultsClient
    ) {
        self.userDefaults = userDefaults
    }
}

public let languageReducer = Reducer<
    LanguageState,
        LanguageAction,
        LanguageEnvironment
> { state, action, environment in
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
