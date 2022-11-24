import ComposableArchitecture
import Models
import Foundation
import Dependencies

extension DependencyValues {
  public var pdfKitClient: PDFKitClient {
    get { self[PDFKitClient.self] }
    set { self[PDFKitClient.self] = newValue }
  }
}

public struct PDFKitClient {
    public var generatePDF: ([[Entry]], Date) -> Effect<Data, Never>
    
    public init(
        generatePDF: @escaping ([[Entry]], Date) -> Effect<Data, Never>
    ) {
        self.generatePDF = generatePDF
    }
}
