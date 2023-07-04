import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import PDFPreviewFeature
import Models

public struct ExportView: View {
	let store: StoreOf<ExportFeature>
	
	public init(
		store: StoreOf<ExportFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
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
					.onTapGesture { viewStore.send(.pdfPreviewButtonTapped) }
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
						viewStore.send(.processPDF)
					}
				}
			}
			.fullScreenCover(
				store: self.store.scope(
					state: \.$pdfPreview,
					action: ExportFeature.Action.pdfPreview)
				) { store in
					NavigationView {
						PDFPreviewView(store: store)
							.toolbar {
								ToolbarItem(placement: .primaryAction) {
									Button {
										viewStore.send(.pdfPreview(.dismiss))
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
		}
		.navigationBarTitle("Settings.ExportPDF".localized)
	}
}
