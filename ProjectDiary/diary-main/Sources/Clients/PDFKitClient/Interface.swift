import Dependencies
import Foundation
import Models

extension DependencyValues {
  public var pdfKitClient: PDFKitClient {
	 get { self[PDFKitClient.self] }
	 set { self[PDFKitClient.self] = newValue }
  }
}

public struct PDFKitClient {
	 public var generatePDF: @Sendable ([[Entry]], Date) async -> Data
	 
	 public init(
		  generatePDF: @escaping @Sendable ([[Entry]], Date) async -> Data
	 ) {
		  self.generatePDF = generatePDF
	 }
}
