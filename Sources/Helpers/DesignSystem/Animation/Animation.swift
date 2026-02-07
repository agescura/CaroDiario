import SwiftUI

extension Animation {
  public static var custom: Self {
    .spring(response: 0.6, dampingFraction: 0.7)
  }
}
