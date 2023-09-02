import ComposableArchitecture
import SwiftUI

public struct AttachmentRowAudioDetailView: View {
	private let store: StoreOf<AttachmentRowAudioDetailFeature>
	@State private var presented = false
	
	public init(
		store: StoreOf<AttachmentRowAudioDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
			VStack {
				
				Spacer()
				
				Group {
					ZStack(alignment: .leading) {
						Capsule()
							.fill(Color.black.opacity(0.08))
							.frame(height: 8)
						Capsule()
							.fill(Color.red)
							.frame(width: viewStore.playerProgress, height: 8)
							.animation(nil, value: UUID())
					}
					
					HStack {
						Text(viewStore.playerProgressTime.formatter)
							.adaptiveFont(.latoRegular, size: 10)
							.foregroundColor(.chambray)
						
						Spacer()
						
						Text(viewStore.playerDuration.formatter)
							.adaptiveFont(.latoRegular, size: 10)
							.foregroundColor(.chambray)
					}
					
					HStack {
						
						Button {} label: {}
							.frame(width: 24, height: 24)
							.opacity(0)
						
						Spacer()
						
						HStack(spacing: 42) {
							Button {
								viewStore.send(.playButtonTapped)
							} label: {
								Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(width: 32, height: 32)
									.foregroundColor(.chambray)
							}
						}
						Spacer()
					}
				}
				.padding()
				.animation(.default, value: UUID())
				
				Spacer()
			}
			.sheet(isPresented: self.$presented) {
				ActivityView(activityItems: [NSData(contentsOfFile: viewStore.entryAudio.url.absoluteString) ?? Data()])
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
					action: AttachmentRowAudioDetailFeature.Action.alert
				)
			)
		}
	}
}
