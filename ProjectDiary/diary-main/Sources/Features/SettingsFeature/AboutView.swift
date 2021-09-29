//
//  AboutView.swift
//
//  Created by Albert Gil Escura on 24/9/21.
//

import SwiftUI
import ComposableArchitecture
import SharedViews
import UIApplicationClient

public struct AboutState: Equatable {
    
}

public enum AboutAction: Equatable {
    case reportBug
}

public struct AboutEnvironment {
    public let applicationClient: UIApplicationClient
}

public let aboutReducer = Reducer<AboutState, AboutAction, AboutEnvironment> { state, action, environment in
    switch action {
    case .reportBug:
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "carodiarioapp@gmail.com"
        components.queryItems = [
          URLQueryItem(name: "subject", value: "Bug in Caro Diario"),
        ]

        return environment.applicationClient.open(components.url!, [:])
          .fireAndForget()
    }
}

public struct AboutView: View {
    let store: Store<AboutState, AboutAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                
                Form {
                    Section() {
                        HStack(spacing: 16) {
                            Text("Settings.Version".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Text("1.0")
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                        }
                    }
                    
                    Section() {
                        HStack(spacing: 16) {
                            
                            Text("Settings.ReportBug".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.reportBug)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Settings.About".localized)
    }
}
