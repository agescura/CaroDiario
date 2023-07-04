import Foundation
import Dependencies

extension UserDefaultsClient: DependencyKey {
  public static var liveValue: UserDefaultsClient { .live }
}

extension UserDefaultsClient {
  public static var live: Self {
    let defaults = { UserDefaults(suiteName: "group.albertgil.carodiario")! }
    return Self(
		setObject: { defaults().set($0, forKey: $1) },
		objectForKey: { defaults().object(forKey: $0) }
    )
  }
}
