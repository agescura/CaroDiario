import ComposableArchitecture
import Foundation
import UIApplicationClient

enum MailType: String {
  case mail = "mailto"
  case gmail = "googlemail"
  case outlook = "ms-outlook"
}

public struct About: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var emailOptionSheet: ConfirmationDialogState<Action>?
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case emailOptionSheetButtonTapped
    case dismissEmailOptionSheet
    case openMail
    case openGmail
    case openOutlook
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case .emailOptionSheetButtonTapped:
      var buttons: [ConfirmationDialogState<Action>.Button] = [
        .cancel(.init("Cancel".localized), action: .send(.dismissEmailOptionSheet)),
      ]
      if self.applicationClient.canOpen(URL(string: "mailto://")!) {
        buttons.insert(.default(.init("Apple Mail"), action: .send(.openMail)), at: buttons.count)
      }
      if self.applicationClient.canOpen(URL(string: "googlegmail://")!) {
        buttons.insert(.default(.init("Google Gmail"), action: .send(.openGmail)), at: buttons.count)
      }
      if self.applicationClient.canOpen(URL(string: "ms-outlook://")!) {
        buttons.insert(.default(.init("Microsoft Outlook"), action: .send(.openOutlook)), at: buttons.count)
      }
      state.emailOptionSheet = .init(
        title: .init("AddEntry.ChooseOption".localized),
        buttons: buttons
      )
      return .none
      
    case .dismissEmailOptionSheet:
      state.emailOptionSheet = nil
      return .none
      
    case .openMail:
      state.emailOptionSheet = nil
      return .fireAndForget {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "carodiarioapp@gmail.com"
        components.queryItems = [
          URLQueryItem(name: "subject", value: "Bug in Caro Diario"),
          URLQueryItem(name: "body", value: "<Explain your bug here>"),
        ]
        await self.applicationClient.open(components.url!, [:])
      }
      
    case .openGmail:
      state.emailOptionSheet = nil
      return .fireAndForget {
        let compose = "googlegmail:///co?subject=Bug in Caro Diario&body=<Explain your bug here>&to=carodiarioapp@gmail.com"
          .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: compose)!
        await self.applicationClient.open(url, [:])
      }
      
    case .openOutlook:
      state.emailOptionSheet = nil
      return .fireAndForget {
        let compose = "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug in Caro Diario&body=<Explain your bug here>"
          .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: compose)!
        await self.applicationClient.open(url, [:])
      }
    }
  }
}
