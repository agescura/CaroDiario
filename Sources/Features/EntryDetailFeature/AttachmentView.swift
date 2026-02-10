import AVKit
import ComposableArchitecture
import SwiftUI

public struct AttachmentView: View {
  let store: StoreOf<AttachmentFeature>
  
  public var body: some View {
    switch store.attachment.format {
    case "image":
      if let image = UIImage(data: store.attachment.data) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      }
    case "video":
      Text("SHOW VIDEO")
    default:
      EmptyView()
    }
  }
}
