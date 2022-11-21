import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAudioRecorderClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    create: XCTUnimplemented("\(Self.self).create"),
    destroy: XCTUnimplemented("\(Self.self).destroy"),
    record: XCTUnimplemented("\(Self.self).record"),
    stop: XCTUnimplemented("\(Self.self).stop")
  )
}

extension AVAudioRecorderClient {
    public static var noop = Self(
        create: { _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        record: { _, _ in .fireAndForget {} },
        stop: { _ in .fireAndForget {} }
    )
}
