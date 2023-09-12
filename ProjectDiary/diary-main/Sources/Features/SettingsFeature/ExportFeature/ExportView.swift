import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import PDFPreviewFeature
import Models

public struct ExportView: View {
	private let store: StoreOf<ExportFeature>
	
	public init(
		store: StoreOf<ExportFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
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
				.onTapGesture { store.send(.previewPDFButtonTapped) }
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
					store.send(.processPDF)
				}
			}
		}
		.fullScreenCover(
			store: self.store.scope(
				state: \.$pdfPreview,
				action: ExportFeature.Action.pdfPreview
			)
		) { previewStore in
			NavigationView {
				PDFPreviewView(store: previewStore)
					.toolbar {
						ToolbarItem(placement: .primaryAction) {
							Button{
								store.send(.pdfPreview(.dismiss))
							} label: {
							  Image(.xmark)
								 .resizable()
								 .frame(width: 18, height: 18)
								 .foregroundColor(.chambray)
							}
						}
					}
			}
		}
		.navigationBarTitle("Settings.ExportPDF".localized)
	}
}
