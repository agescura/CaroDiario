import ComposableArchitecture
import Foundation
import Models
import PDFKitClient
import PDFPreviewFeature
import UIApplicationClient

public struct ExportFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		var pdf = Data()
		@PresentationState var pdfPreview: PDFPreview.State?
		var presentPreview = false
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case generatePDF([[Entry]])
		case generatePreview([[Entry]])
		case pdfPreview(PresentationAction<PDFPreview.Action>)
		case presentActivityView(Data)
		case presentPDFPreview
		case presentPreviewView(Data)
		case previewPDFButtonTapped
		case processPDF
	}
	
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.pdfKitClient) private var pdfKitClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .processPDF:
					return .none
					
				case let .generatePDF(entries):
					return .run { send in
						await send(.presentActivityView(self.pdfKitClient.generatePDF(entries, self.now)))
					}
					
				case let .presentActivityView(file):
					self.applicationClient.share(file, .pdf)
					return .none
					
				case .previewPDFButtonTapped:
					return .none
					
				case let .generatePreview(entries):
					return .run { send in
						await send(.presentPreviewView(self.pdfKitClient.generatePDF(entries, self.now)))
					}
					
				case let .presentPreviewView(file):
					state.pdf = file
					return .send(.presentPDFPreview)
					
				case .presentPDFPreview:
					state.pdfPreview = PDFPreview.State(pdfData: state.pdf)
					return .none
					
				case .pdfPreview:
					return .none
			}
		}
		.ifLet(\.$pdfPreview, action: /Action.pdfPreview) {
			PDFPreview()
		}
	}
}
