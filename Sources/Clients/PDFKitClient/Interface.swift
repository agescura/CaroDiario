import Dependencies
import DependenciesMacros
import Foundation
import Models

extension DependencyValues {
  public var pdfKitClient: PDFKitClient {
    get { self[PDFKitClient.self] }
    set { self[PDFKitClient.self] = newValue }
  }
}

@DependencyClient
public struct PDFKitClient: Sendable {
    public var generatePDF: @Sendable ([[Entry]], Date) async throws -> Data
}
