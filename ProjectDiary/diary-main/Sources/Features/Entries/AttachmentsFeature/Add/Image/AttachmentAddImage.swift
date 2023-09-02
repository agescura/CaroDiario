import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import Views
import Models
import UIApplicationClient

public struct AttachmentAddImage: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var entryImage: EntryImage
		public var presentImageFullScreen: Bool = false
		
		public var removeFullScreenAlert: AlertState<AttachmentAddImage.Action>?
		public var removeAlert: AlertState<AttachmentAddImage.Action>?
		
		public var imageScale: CGFloat = 1
		public var lastValue: CGFloat = 1
		public var dragged: CGSize = .zero
		public var previousDragged: CGSize = .zero
		public var pointTapped: CGPoint = .zero
		public var isTapped: Bool = false
		public var currentPosition: CGSize = .zero
		
		public init(
			entryImage: EntryImage
		) {
			self.entryImage = entryImage
		}
	}
	
	public enum Action: Equatable {
		case imageButtonTapped
		case presentImageFullScreen(Bool)
		
		case remove
		case removeFullScreenAlertButtonTapped
		case dismissRemoveFullScreen
		case cancelRemoveFullScreenAlert
		
		case scaleOnChanged(CGFloat)
		case scaleTapGestureCount
		case dragGesture(DragGesture.Value)
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .imageButtonTapped:
				return .none
				
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
}

struct AttachmentAddImageView: View {
	private let store: StoreOf<AttachmentAddImage>
	@State private var presented = false
	
	init(
		store: StoreOf<AttachmentAddImage>
	) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
			ImageView(url: viewStore.entryImage.thumbnail)
				.frame(width: 52, height: 52)
				.onTapGesture {
					viewStore.send(.imageButtonTapped)
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
