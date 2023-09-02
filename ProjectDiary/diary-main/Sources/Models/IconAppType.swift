import Foundation

public enum IconAppType: String, CaseIterable {
    case light = "Style.Light"
    case dark = "Style.Dark"
    
    public var icon: String {
        switch self {
        case .light:
            return "Icon-1"
        case .dark:
            return "Icon-2"
        }
    }
}
