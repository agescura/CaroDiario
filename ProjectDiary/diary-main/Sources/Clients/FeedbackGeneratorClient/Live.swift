import UIKit
import Dependencies

extension FeedbackGeneratorClient: DependencyKey {
  public static var liveValue: FeedbackGeneratorClient { .live }
}

extension FeedbackGeneratorClient {
    public static var live: Self {
        let generator = UISelectionFeedbackGenerator()
        return Self(
            prepare: { generator.prepare() },
            selectionChanged: { generator.selectionChanged() }
        )
    }
}
