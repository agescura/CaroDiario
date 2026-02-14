import Dependencies
import Foundation

extension FileClient: TestDependencyKey {
  public static var testValue: FileClient {
    FileClient(
      removeAttachments: { _ in },
      addImage: { _ in },
      addVideo: { _ in }
    )
  }
}
