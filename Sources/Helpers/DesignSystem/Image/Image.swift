import Foundation
import SwiftUI

extension Image {
  public init(
    systemName: SystemImage
  ) {
    self.init(systemName: systemName.rawValue)
  }
}

#Preview {
  NavigationStack {
    List {
      ForEach(SystemImage.allCases, id: \.self) { image in
        LabeledContent(image.rawValue) {
          Image(systemName: image)
        }
      }
    }
  }
}
