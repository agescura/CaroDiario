import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import PDFPreviewFeature
import Models

public struct ExportView: View {
	@Perception.Bindable var store: StoreOf<ExportFeature>
	
	public init(
		store: StoreOf<ExportFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithPerceptionTracking {
			Form {
				Section() {
					HStack(spacing: 16) {
						IconImageView(
							.docTextMagnifyingglass,
							foregroundColor: .berryRed
						)
						
						Text("PDF.Preview".localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
						Spacer()
						Image(.infoCircle)
							.foregroundColor(.blue)
					}
					.contentShape(Rectangle())
					.onTapGesture { self.store.send(.generatePreview) }
				}
				
				Section() {
					HStack(spacing: 16) {
						IconImageView(
							.squareAndArrowUp,
							foregroundColor: .green
						)
						
						Text("PDF.Share".localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
						Spacer()
						Image(.infoCircle)
							.foregroundColor(.blue)
					}
					.contentShape(Rectangle())
					.onTapGesture {
						self.store.send(.generatePDF)
					}
				}
			}
			.fullScreenCover(
				item: self.$store.scope(state: \.pdfPreview, action: \.pdfPreview)
			) { store in
				PDFPreviewView(store: store)
			}
		}
		.navigationBarTitle("Settings.ExportPDF".localized)
	}
}
