import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension AVAudioPlayerClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    create: XCTUnimplemented("\(Self.self).path"),
    destroy: XCTUnimplemented("\(Self.self).removeAttachments"),
    duration: XCTUnimplemented("\(Self.self).addImage"),
    play: XCTUnimplemented("\(Self.self).loadImage"),
    pause: XCTUnimplemented("\(Self.self).addVideo"),
    stop: XCTUnimplemented("\(Self.self).addAudio"),
    isPlaying: XCTUnimplemented("\(Self.self).addAudio"),
    currentTime: XCTUnimplemented("\(Self.self).addAudio"),
    setCurrentTime: XCTUnimplemented("\(Self.self).addAudio")
  )
}

extension AVAudioPlayerClient {
    public static var noop = Self(
        create: { _, _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        duration: { _ in .fireAndForget {} },
        play: { _ in .fireAndForget {} },
        pause: { _ in .fireAndForget {} },
        stop: { _ in .fireAndForget {} },
        isPlaying: { _ in .fireAndForget {} },
        currentTime: { _ in .fireAndForget {} },
        setCurrentTime: { _, _ in .fireAndForget {} }
    )
}
