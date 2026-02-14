import AVKit
import ComposableArchitecture
import SwiftUI

public struct AttachmentView: View {
  let store: StoreOf<AttachmentFeature>
  
  public var body: some View {
    switch store.attachment.format {
    case .image:
      AsyncImage(url: store.attachment.fileUrl) { image in
        image
          .resizable()
          .scaledToFill()
      } placeholder: {
        ProgressView()
      }
    case .video:
      VideoPlayer(player: AVPlayer(url: store.attachment.fileUrl))
    case .audio:
      Text("SHOW AUDIO")
    }
  }
}
