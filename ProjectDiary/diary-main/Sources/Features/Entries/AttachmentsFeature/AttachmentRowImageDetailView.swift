import ComposableArchitecture
import SwiftUI
import Views

public struct AttachmentRowImageDetailView: View {
	let store: StoreOf<AttachmentRowImageDetailFeature>
	@State private var presented = false
	
	public init(
		store: StoreOf<AttachmentRowImageDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
			ImageView(url: viewStore.entryImage.url)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.animation(.easeIn(duration: 1.0), value: UUID())
				.scaleEffect(viewStore.imageScale)
				.offset(viewStore.currentPosition)
				.gesture(
					MagnificationGesture(minimumScaleDelta: 0.1)
						.onChanged { value in
							viewStore.send(.scaleOnChanged(value))
						}
						.simultaneously(
							with: TapGesture(count: 2)
								.onEnded {
									viewStore.send(.scaleTapGestureCount, animation: .spring())
								}
						)
						.simultaneously(
							with: DragGesture()
								.onChanged { value in
									viewStore.send(.dragGesture(value), animation: .spring())
								}
						)
				)
				.sheet(isPresented: self.$presented) {
					ActivityView(activityItems: [UIImage(contentsOfFile: viewStore.entryImage.url.absoluteString) ?? Data()])
				}
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button {
							viewStore.send(.alertButtonTapped)
						} label: {
							Image(systemName: "trash")
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 16, height: 16)
								.foregroundColor(.chambray)
						}
					}
				}
				.alert(
					store: self.store.scope(
						state: \.$alert,
						action: AttachmentRowImageDetailFeature.Action.alert
					)
				)
		}
	}
}

extension AlertState where Action == AttachmentRowImageDetailFeature.Action.Alert {
	static var remove: Self {
		AlertState {
			TextState("Image.Remove.Description".localized)
		} actions: {
			ButtonState.destructive(.init("Image.Remove.Title".localized), action: .send(.removeButtonTapped))
		}
	}
}
