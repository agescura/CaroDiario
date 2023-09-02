import UIKit

public enum ThemeType: String, CaseIterable, Codable {
    case system = "Style.System"
    case light = "Style.Light"
    case dark = "Style.Dark"
    
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .unspecified
        }
    }
    
    public var icon: String {
        switch self {
        
        case .system:
            return "star.circle.fill"
        case .light:
            return "star.fill"
        case .dark:
            return "star"
        }
    }
}
