import Foundation
import Dependencies

extension UserDefaultsClient: DependencyKey {
  public static var liveValue: UserDefaultsClient { .live }
}

extension UserDefaultsClient {
  public static var live: Self {
		let defaults = { UserDefaults(suiteName: "group.albertgil.carodiario")! }
    return Self(
      boolForKey: defaults().bool(forKey:),
      setBool: { defaults().set($0, forKey: $1) },
      stringForKey: defaults().string(forKey:),
      setString: { defaults().set($0, forKey: $1) },
      intForKey: defaults().integer(forKey:),
      setInt: { defaults().set($0, forKey: $1) },
      dateForKey: { Date(timeIntervalSince1970: defaults().double(forKey: $0)) },
      setDate: { defaults().set($0.timeIntervalSince1970, forKey: $1) },
      remove: { defaults().removeObject(forKey: $0) }
    )
  }
}
