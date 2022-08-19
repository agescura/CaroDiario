//
//  AboutView.swift
//
//  Created by Albert Gil Escura on 24/9/21.
//

import SwiftUI
import ComposableArchitecture
import SharedViews
import UIApplicationClient

enum MailType: String {
    case mail = "mailto"
    case gmail = "googlemail"
    case outlook = "ms-outlook"
}

public struct AboutState: Equatable {
    public var emailOptionSheet: ConfirmationDialogState<AboutAction>?
}

public enum AboutAction: Equatable {
    case emailOptionSheetButtonTapped
    case dismissEmailOptionSheet
    case openMail
    case openGmail
    case openOutlook
}

public struct AboutEnvironment {
    public let applicationClient: UIApplicationClient
}

public let aboutReducer = Reducer<
    AboutState,
    AboutAction,
    AboutEnvironment
> { state, action, environment in
    switch action {
    case .emailOptionSheetButtonTapped:
        var buttons: [ConfirmationDialogState<AboutAction>.Button] = [
            .cancel(.init("Cancel".localized), action: .send(.dismissEmailOptionSheet)),
            .default(.init("Apple Mail"), action: .send(.openMail)),
        ]
        if environment.applicationClient.canOpen(URL(string: "googlegmail://")!) {
            buttons.insert(.default(.init("Google Gmail"), action: .send(.openGmail)), at: buttons.count)
        }
        if environment.applicationClient.canOpen(URL(string: "ms-outlook://")!) {
            buttons.insert(.default(.init("Microsoft Outlook"), action: .send(.openOutlook)), at: buttons.count)
        }
        state.emailOptionSheet = .init(
            title: .init("AddEntry.ChooseOption".localized),
            buttons: buttons
        )
        return .none
        
    case .dismissEmailOptionSheet:
        return .none
        
    case .openMail:
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "carodiarioapp@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Bug in Caro Diario"),
            URLQueryItem(name: "body", value: "<Explain your bug here>"),
        ]
        
        return environment.applicationClient.open(components.url!, [:])
            .fireAndForget()
        
    case .openGmail:
        let compose = "googlegmail:///co?subject=Bug in Caro Diario&body=<Explain your bug here>&to=carodiarioapp@gmail.com"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: compose)!
        
        return environment.applicationClient.open(url, [:])
            .fireAndForget()
        
    case .openOutlook:
        let compose = "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug in Caro Diario&body=<Explain your bug here>"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: compose)!
        
        return environment.applicationClient.open(url, [:])
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
                            viewStore.send(.emailOptionSheetButtonTapped)
                        }
                        .confirmationDialog(
                            store.scope(state: \.emailOptionSheet),
                            dismiss: .dismissEmailOptionSheet
                        )
                    }
                }
            }
        }
        .navigationBarTitle("Settings.About".localized)
    }
}
