import Foundation
import SwiftUI

extension Image {
  public init(
    _ name: SystemImage
  ) {
    self.init(systemName: name.rawValue)
  }
}

struct Image_Preview: PreviewProvider {
  static var previews: some View {
    NavigationView {
      List {
        ForEach(SystemImage.allCases, id: \.self) { image in
          HStack {
            Text(image.rawValue)
            Spacer()
            Image(image)
          }
        }
      }
    }
  }
}
