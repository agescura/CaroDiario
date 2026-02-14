import Foundation

public enum Spacing {
  case s0, s1, s2, s4, s8, s16, s32, s64, custom(CGFloat)
  
  public var rawValue: CGFloat {
    switch self {
    case .s0: 0
    case .s1: 1
    case .s2: 2
    case .s4: 4
    case .s8: 8
    case .s16: 16
    case .s32: 32
    case .s64: 64
    case let .custom(spacing): spacing
    }
  }
}
