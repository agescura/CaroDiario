import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import Views
import Models
import UIApplicationClient

public struct AttachmentAddImage: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entryImage: EntryImage
		public var presentImageFullScreen: Bool = false
		
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
		case alert(PresentationAction<Alert>)
		case presentImageFullScreen(Bool)
		
		case removeFullScreenAlertButtonTapped
		
		case scaleOnChanged(CGFloat)
		case scaleTapGestureCount
		case dragGesture(DragGesture.Value)
		
		public enum Alert: Equatable {
			case remove
		}
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.remove)):
					state.presentImageFullScreen = false
					return .none
				case .alert:
					return .none
					
				case let .presentImageFullScreen(value):
					state.presentImageFullScreen = value
					return .none
					
				case .removeFullScreenAlertButtonTapped:
					state.alert = AlertState {
						TextState("Image.Remove.Description".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(role: .destructive, action: .remove, label: { TextState("Image.Remove.Title".localized) })
					}
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
		.ifLet(\.$alert, action: /Action.alert)
	}
}

struct AttachmentAddImageView: View {
	let store: StoreOf<AttachmentAddImage>
	@State private var presented = false
	
	init(
		store: StoreOf<AttachmentAddImage>
	) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ImageView(url: viewStore.entryImage.thumbnail)
				.frame(width: 52, height: 52)
				.onTapGesture {
					viewStore.send(.presentImageFullScreen(true))
				}
				.fullScreenCover(isPresented: viewStore.binding(
					get: \.presentImageFullScreen,
					send: AttachmentAddImage.Action.presentImageFullScreen)
				) {
					ZStack(alignment: .topTrailing) {
						ImageView(url: viewStore.entryImage.url)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.animation(.easeIn(duration: 1.0), value: UUID())
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
								Image(.trash)
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(width: 16, height: 16)
									.foregroundColor(.chambray)
							}
							
							Button(action: {
								viewStore.send(.presentImageFullScreen(false))
							}) {
								Image(.xmark)
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(width: 16, height: 16)
									.foregroundColor(.chambray)
							}
						}
						.padding()
					}
					.alert(
						store: self.store.scope(state: \.$alert, action: { .alert($0) })
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
