import ComposableArchitecture

@Reducer
public struct AttachmentFeature {
  public init() {}
  @ObservableState
  public struct State: Equatable, Sendable {
    var attachment: Attachment
  }
  public enum Action: Equatable {
  }
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}
