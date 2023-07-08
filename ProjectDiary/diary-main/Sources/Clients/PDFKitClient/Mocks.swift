import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PDFKitClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
	 generatePDF: XCTUnimplemented("\(Self.self).generatePDF")
  )
}

extension PDFKitClient {
	 public static let noop = Self(
		  generatePDF: { _, _ in Data() }
	 )
}
