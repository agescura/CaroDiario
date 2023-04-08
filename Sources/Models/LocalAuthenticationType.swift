import Foundation

public enum LocalAuthenticationType {
  case faceId
  case touchId
  case none
  
  public var rawValue: String {
    switch self {
    case .faceId:
      return "Face ID"
    case .touchId:
      return "Touch ID"
    case .none:
      return ""
    }
  }
}
