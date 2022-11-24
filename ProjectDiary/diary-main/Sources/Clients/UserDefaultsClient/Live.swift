import Foundation
import Dependencies

extension UserDefaultsClient: DependencyKey {
  public static var liveValue: UserDefaultsClient { .live() }
}

extension UserDefaultsClient {
    public static func live(userDefaults: UserDefaults = UserDefaults(suiteName: "group.albertgil.carodiario")!) -> Self {
        Self(
            boolForKey: userDefaults.bool(forKey:),
            setBool: { value, key in
                .fireAndForget {
                    userDefaults.set(value, forKey: key)
                }
            },
            stringForKey: userDefaults.string(forKey:),
            setString: { value, key in
                .fireAndForget {
                    userDefaults.set(value, forKey: key)
                }
            },
            intForKey: userDefaults.integer(forKey:),
            setInt: { value, key in
                .fireAndForget {
                    userDefaults.set(value, forKey: key)
                }
            },
            dateForKey: { key in
                Date(timeIntervalSince1970: userDefaults.double(forKey: key))
            },
            setDate: { value, key in
                .fireAndForget {
                    userDefaults.set(value.timeIntervalSince1970, forKey: key)
                }
            },
            remove: { key in
                .fireAndForget {
                    userDefaults.removeObject(forKey: key)
                }
            }
        )
    }
}
