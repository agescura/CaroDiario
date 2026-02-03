import UIKit
import Dependencies

extension ApplicationClient: DependencyKey {
  public static var liveValue: Self { .live }
}

extension ApplicationClient {
  public static var live: Self {
    Self(
      open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
    )
  }
}
