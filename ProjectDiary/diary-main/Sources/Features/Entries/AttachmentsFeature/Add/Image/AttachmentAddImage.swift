import ComposableArchitecture
import Models
import Views
import SwiftUI


@Reducer
public struct AttachmentAddImage {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var alert: AlertState<Action.Alert>?
		public var currentPosition: CGSize = .zero
		public var dragged: CGSize = .zero
		public var entryImage: EntryImage
		public var imageScale: CGFloat = 1
		public var isTapped: Bool = false
		public var lastValue: CGFloat = 1
		public var pointTapped: CGPoint = .zero
		public var presentImageFullScreen: Bool = false
		public var previousDragged: CGSize = .zero
		
		public init(
			entryImage: EntryImage
		) {
			self.entryImage = entryImage
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case dragGesture(DragGesture.Value)
		case presentImageFullScreen(Bool)
		case removeFullScreenAlertButtonTapped
		case scaleOnChanged(CGFloat)
		case scaleTapGestureCount
		
		@CasePathable
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
		.ifLet(\.$alert, action: \.alert)
	}
}

struct AttachmentAddImageView: View {
	@Perception.Bindable var store: StoreOf<AttachmentAddImage>
	@State private var presented = false
	
	init(
		store: StoreOf<AttachmentAddImage>
	) {
		self.store = store
	}
	
	var body: some View {
		WithPerceptionTracking {
			ImageView(url: self.store.entryImage.thumbnail)
				.frame(width: 52, height: 52)
				.onTapGesture {
					self.store.send(.presentImageFullScreen(true))
				}
				.fullScreenCover(isPresented: self.$store.presentImageFullScreen.sending(\.presentImageFullScreen)
				) {
					ZStack(alignment: .topTrailing) {
						ImageView(url: self.store.entryImage.url)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.animation(.easeIn(duration: 1.0), value: UUID())
							.scaleEffect(self.store.imageScale)
							.offset(self.store.currentPosition)
							.gesture(
								
								MagnificationGesture(minimumScaleDelta: 0.1)
									.onChanged({ value in
										self.store.send(.scaleOnChanged(value))
									})
									.simultaneously(with: TapGesture(count: 2).onEnded({
										self.store.send(.scaleTapGestureCount, animation: .spring())
									}))
									.simultaneously(with: DragGesture().onChanged({ value in
										self.store.send(.dragGesture(value), animation: .spring())
									}))
								
							)
						HStack(spacing: 32) {
							Button(action: {
								self.store.send(.removeFullScreenAlertButtonTapped)
							}) {
								Image(.trash)
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(width: 16, height: 16)
									.foregroundColor(.chambray)
							}
							
							Button(action: {
								self.store.send(.presentImageFullScreen(false))
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
						store: self.store.scope(state: \.$alert, action: \.alert)
					)
					.sheet(isPresented: self.$presented) {
						ActivityView(activityItems: [UIImage(contentsOfFile: self.store.entryImage.url.absoluteString) ?? Data()])
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
