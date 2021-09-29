//
//  AppDelegate.swift
//  
//
//  Created by Albert Gil Escura on 13/7/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import SharedStyles

public struct AppDelegateState: Equatable {
    
    public init() {}
}

public enum AppDelegateAction: Equatable {
    case didFinishLaunching
}

public let appDelegateReducer = Reducer<AppDelegateState, AppDelegateAction, Void> { state, action, _ in
    switch action {
    case .didFinishLaunching:
        
        guard let latoRegular16 = UIFont(name:"Lato-Regular", size: 16),
              let latoRegular40 = UIFont(name:"Lato-Regular", size: 40) else { return .none }
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(.chambray),
            .font : latoRegular16
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(.chambray),
            .font : latoRegular40
        ]
        
        return .none
    }
}
