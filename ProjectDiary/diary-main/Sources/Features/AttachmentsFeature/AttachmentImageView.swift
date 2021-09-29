//
//  AddEntryImagesView.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 4/7/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import SharedViews
import SharedModels
import UIApplicationClient

public struct AttachmentImageState: Equatable {
    public var entryImage: SharedModels.EntryImage
    public var presentImageFullScreen: Bool = false
    
    public var removeFullScreenAlert: AlertState<AttachmentImageAction>?
    public var removeAlert: AlertState<AttachmentImageAction>?
    
    public var imageScale: CGFloat = 1
    public var lastValue: CGFloat = 1
    public var dragged: CGSize = .zero
    public var previousDragged: CGSize = .zero
    public var pointTapped: CGPoint = .zero
    public var isTapped: Bool = false
    public var currentPosition: CGSize = .zero

    public init(
        entryImage: SharedModels.EntryImage
    ) {
        self.entryImage = entryImage
    }
}

public enum AttachmentImageAction: Equatable {
    case presentImageFullScreen(Bool)
    
    case remove
    case removeFullScreenAlertButtonTapped
    case dismissRemoveFullScreen
    case cancelRemoveFullScreenAlert
    
    case processShare
    case shareImage(Data)
    
    case scaleOnChanged(CGFloat)
    case scaleTapGestureCount
    case dragGesture(DragGesture.Value)
}

public struct AttachmentImageEnvironment {
    public let fileClient: FileClient
    public let applicationClient: UIApplicationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        fileClient: FileClient,
        applicationClient: UIApplicationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.fileClient = fileClient
        self.applicationClient = applicationClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }
}

public let attachmentImageReducer = Reducer<AttachmentImageState, AttachmentImageAction, AttachmentImageEnvironment> { state, action, environment in
    switch action {
    
    case let .presentImageFullScreen(value):
        state.presentImageFullScreen = value
        return .none
        
    case .removeFullScreenAlertButtonTapped:
        state.removeFullScreenAlert = .init(
            title: .init("Image.Remove.Description".localized),
            primaryButton: .cancel(.init("Cancel".localized)),
            secondaryButton: .destructive(.init("Image.Remove.Title".localized), action: .send(.remove))
        )
        return .none
        
    case .dismissRemoveFullScreen:
        state.removeFullScreenAlert = nil
        state.presentImageFullScreen = false
        return .none
        
    case .remove:
        state.presentImageFullScreen = false
        state.removeFullScreenAlert = nil
        return .none
        
    case .cancelRemoveFullScreenAlert:
        state.removeFullScreenAlert = nil
        return .none
        
    case .processShare:
        return environment.fileClient.loadImage(state.entryImage, environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(AttachmentImageAction.shareImage)
                
    case let .shareImage(image):
        return environment.applicationClient.share(image)
            .fireAndForget()
        
    case let .scaleOnChanged(value):
        let maxScale: CGFloat = 3.0
        let minScale: CGFloat = 1.0
        
        let resolvedDelta = value / state.imageScale
        state.lastValue = value
        let newScale = state.imageScale * resolvedDelta
        state.imageScale = min(maxScale, max(minScale, newScale))
        return .none
        
    case .scaleTapGestureCount:
        state.isTapped.toggle()
        state.imageScale = state.imageScale > 1 ? 1 : 2
        state.currentPosition = .zero
        return .none
        
    case let .dragGesture(value):
        state.currentPosition = .init(width: value.translation.width, height: value.translation.height)
        return .none
    }
}

struct AttachmentImageView: View {
    let store: Store<AttachmentImageState, AttachmentImageAction>
    
    @State private var presented = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ImageView(url: viewStore.entryImage.thumbnail)
                .frame(width: 52, height: 52)
                .onTapGesture {
                    viewStore.send(.presentImageFullScreen(true))
                }
                .fullScreenCover(isPresented: viewStore.binding(
                                    get: \.presentImageFullScreen,
                                    send: AttachmentImageAction.presentImageFullScreen)
                ) {
                    ZStack(alignment: .topTrailing) {
                        ImageView(url: viewStore.entryImage.url)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .animation(.easeIn(duration: 1.0))
                            .scaleEffect(viewStore.imageScale)
                            .offset(viewStore.currentPosition)
                            .gesture(
                                
                                MagnificationGesture(minimumScaleDelta: 0.1)
                                    .onChanged({ value in
                                        viewStore.send(.scaleOnChanged(value))
                                    })
                                    .simultaneously(with: TapGesture(count: 2).onEnded({
                                        viewStore.send(.scaleTapGestureCount, animation: .spring())
                                    }))
                                    .simultaneously(with: DragGesture().onChanged({ value in
                                        viewStore.send(.dragGesture(value), animation: .spring())
                                    }))
                                
                            )
                        HStack(spacing: 32) {
                            Button(action: {
                                viewStore.send(.removeFullScreenAlertButtonTapped)
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.chambray)
                            }
                            
                            Button(action: {
                                viewStore.send(.processShare)
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.chambray)
                            }
                            
                            
                            Button(action: {
                                viewStore.send(.presentImageFullScreen(false))
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.chambray)
                            }
                        }
                        .padding()
                    }
                    .alert(
                        store.scope(state: \.removeFullScreenAlert),
                        dismiss: .cancelRemoveFullScreenAlert
                    )
                    .sheet(isPresented: self.$presented) {
                        ActivityView(activityItems: [UIImage(contentsOfFile: viewStore.entryImage.url.absoluteString) ?? Data()])
                    }
                }
        }
    }
}

public struct ActivityView: UIViewControllerRepresentable {
    public var activityItems: [Any]
    @Environment(\.presentationMode) var presentationMode
    
    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: self.activityItems,
            applicationActivities: nil
        )
        controller.modalPresentationStyle = .pageSheet
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.presentationMode.wrappedValue.dismiss()
        }
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
