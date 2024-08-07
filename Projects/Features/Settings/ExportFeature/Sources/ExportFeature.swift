import ComposableArchitecture
import CoreDataClient
import Foundation
import Models
import PDFKitClient
import PDFPreviewFeature
import UIApplicationClient

@Reducer
public struct ExportFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Presents var pdfPreview: PDFPreviewFeature.State?
		var pdf = Data()
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case generatePDF
		case presentActivityView(Data)
		case generatePreview
		case presentPreviewView(Data)
		case pdfPreview(PresentationAction<PDFPreviewFeature.Action>)
	}
	
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.pdfKitClient) var pdfKitClient
	@Dependency(\.coreDataClient) var coreDataClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .generatePDF:
					return .run { send in
						let entries = await self.coreDataClient.fetchAll()
						await send(.presentActivityView(self.pdfKitClient.generatePDF(entries, self.now)))
					}
					
				case let .presentActivityView(file):
					self.applicationClient.share(file, .pdf)
					return .none
					
				case .generatePreview:
					return .run { send in
						let entries = await self.coreDataClient.fetchAll()
						await send(.presentPreviewView(self.pdfKitClient.generatePDF(entries, self.now)))
					}
					
				case let .presentPreviewView(file):
					state.pdf = file
					state.pdfPreview = PDFPreviewFeature.State(pdfData: state.pdf)
					return .none
					
				case .pdfPreview(.presented(.dismiss)):
					state.pdfPreview = nil
					return .none
					
				case .pdfPreview:
					return .none
			}
		}
		.ifLet(\.$pdfPreview, action: \.pdfPreview) {
			PDFPreviewFeature()
		}
	}
}
