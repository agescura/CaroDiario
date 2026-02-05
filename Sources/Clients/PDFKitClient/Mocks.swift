import Foundation
import Dependencies
import XCTestDynamicOverlay

extension PDFKitClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
		generatePDF: unimplemented("\(Self.self).generatePDF", placeholder: Data())
  )
}

extension PDFKitClient {
  public static var noop: PDFKitClient {
    PDFKitClient(
      generatePDF: { _, _ in Data() }
    )
  }
}
