import Dependencies

extension DependencyValues {
  public var feedbackGeneratorClient: FeedbackGeneratorClient {
    get { self[FeedbackGeneratorClient.self] }
    set { self[FeedbackGeneratorClient.self] = newValue }
  }
}

public struct FeedbackGeneratorClient {
    public var prepare: () async -> Void
    public var selectionChanged: () async -> Void
    
    public init(
        prepare: @escaping () async -> Void,
        selectionChanged: @escaping () async -> Void
    ) {
        self.prepare = prepare
        self.selectionChanged = selectionChanged
    }
}
