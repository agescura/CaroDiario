import SwiftUI
import ComposableArchitecture
import Views
import Models

public struct AttachmentImage: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var entryImage: EntryImage
    
    public init(
      entryImage: EntryImage
    ) {
      self.entryImage = entryImage
    }
  }
  
  public enum Action: Equatable {
    case presentImageFullScreen(Bool)
  }
  
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

struct AttachmentImageView: View {
  let store: StoreOf<AttachmentImage>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ImageView(url: viewStore.entryImage.thumbnail)
        .frame(width: 52, height: 52)
        .onTapGesture {
          viewStore.send(.presentImageFullScreen(true))
        }
    }
  }
}
