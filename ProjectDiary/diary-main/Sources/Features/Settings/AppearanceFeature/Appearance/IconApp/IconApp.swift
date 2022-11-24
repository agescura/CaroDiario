import Foundation
import ComposableArchitecture
import Models
import UIApplicationClient
import FeedbackGeneratorClient

public struct IconApp: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var iconAppType: IconAppType
    
    public init(
      iconAppType: IconAppType
    ) {
      self.iconAppType = iconAppType
    }
  }
  
  public enum Action: Equatable {
    case iconAppChanged(IconAppType)
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient

  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .iconAppChanged(newIconApp):
      state.iconAppType = newIconApp
      return .fireAndForget {
        try await self.applicationClient.setAlternateIconName(newIconApp == .dark ? "AppIcon-2" : nil)
        await self.feedbackGeneratorClient.selectionChanged()
      }
    }
  }
}
