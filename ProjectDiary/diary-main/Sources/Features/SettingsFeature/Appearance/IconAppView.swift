//
//  IconAppView.swift
//  
//
//  Created by Albert Gil Escura on 15/8/21.
//

import ComposableArchitecture
import SwiftUI
import SharedStyles
import FeedbackGeneratorClient

public struct IconAppState: Equatable {
    public var iconAppType: IconAppType
}

public enum IconAppAction: Equatable {
    case iconAppChanged(IconAppType)
}

public struct IconAppEnvironment {
    public let feedbackGeneratorClient: FeedbackGeneratorClient
}

let iconAppReducer = Reducer<IconAppState, IconAppAction, IconAppEnvironment> { state, action, environment in
    switch action {
    
    case let .iconAppChanged(newIconApp):
        state.iconAppType = newIconApp
        return environment.feedbackGeneratorClient.selectionChanged()
            .fireAndForget()
        
    }
}

public struct IconAppView: View {
    let store: Store<IconAppState, IconAppAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.adaptiveGray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack(spacing: 32) {
                        ForEach(IconAppType.allCases, id: \.self) { iconApp in
                            VStack {
                                Image(iconApp.icon, bundle: .module)
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .onTapGesture {
                                        viewStore.send(.iconAppChanged(iconApp))
                                    }
                                    .overlay(
                                        Text(viewStore.iconAppType == iconApp ? "Selected" : "")
                                            .foregroundColor(.chambray)
                                            .adaptiveFont(.latoRegular, size: 14)
                                            .offset(x: 0, y: 32)
                                        ,
                                        alignment: .bottom
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}
