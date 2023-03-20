import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient
import EntriesFeature
import Models

public struct Style: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
    
    public var skipAlert: AlertState<Style.Action>?
    public var layout: Layout.State? = nil
    public var navigateLayout: Bool = false
    
    public var isAppClip = false
  }

  public enum Action: Equatable {
    case styleChanged(StyleType)
    case entries(id: UUID, action: DayEntriesRow.Action)
    
    case layout(Layout.Action)
    case navigationLayout(Bool)
    
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
  }
  
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.entries, action: /Action.entries) {
        DayEntriesRow()
      }
      .ifLet(\.layout, action: /Action.layout) {
        Layout()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case let .styleChanged(styleChanged):
      state.styleType = styleChanged
      state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
      return .fireAndForget {
        await self.feedbackGeneratorClient.selectionChanged()
      }
      
    case .entries:
      return .none
      
    case .layout:
      return .none
      
    case let .navigationLayout(value):
      state.navigateLayout = value
      state.layout = value ? .init(
        styleType: state.styleType, layoutType: state.layoutType,
        entries: fakeEntries(
          with: state.styleType,
          layout: state.layoutType),
        isAppClip: state.isAppClip) : nil
      return .none
      
    case .skipAlertButtonTapped:
      state.skipAlert = .init(
        title: .init("OnBoarding.Skip.Title".localized),
        message: .init("OnBoarding.Skip.Alert".localized),
        primaryButton: .cancel(.init("Cancel".localized), action: .send(.cancelSkipAlert)),
        secondaryButton: .destructive(.init("OnBoarding.Skip".localized), action: .send(.skipAlertAction))
      )
      return .none
      
    case .cancelSkipAlert:
      state.skipAlert = nil
      return .fireAndForget {
        await self.feedbackGeneratorClient.selectionChanged()
      }
      
    case .skipAlertAction:
      state.skipAlert = nil
      return .fireAndForget { await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true) }
    }
  }
}
