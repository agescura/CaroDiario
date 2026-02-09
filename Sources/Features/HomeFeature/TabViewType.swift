import Foundation

public enum TabViewType {
    case entries
    case search
    case settings
}

extension TabViewType {
    public var rawValue: String {
        switch self {
        case .entries:
            return "Home.TabView.Entries".localized
        case .search:
            return "Home.TabView.Search".localized
        case .settings:
            return "Home.TabView.Settings".localized
        }
    }
    
    public var icon: String {
        switch self {
        case .entries:
            return "note.text"
        case .search:
            return "magnifyingglass"
        case .settings:
            return "gear"
        }
    }
    
    public var hasPlusButton: Bool {
        switch self {
        case .entries:
            return true
        default:
            return false
        }
    }
}
