import Foundation
import SwiftUI

extension Image {
    public init(
        _ name: SystemImage
    ) {
        self.init(systemName: name.rawValue)
    }
}
