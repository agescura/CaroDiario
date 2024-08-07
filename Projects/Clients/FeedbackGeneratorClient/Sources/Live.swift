//import UIKit
//import Dependencies
//
//extension FeedbackGeneratorClient: DependencyKey {
//  public static var liveValue: FeedbackGeneratorClient { .live }
//}
//
//extension FeedbackGeneratorClient {
//    public static var live: Self {
//        let generator = UISelectionFeedbackGenerator()
//        return Self(
//            prepare: { await generator.prepare() },
//            selectionChanged: { await generator.selectionChanged() }
//        )
//    }
//}
