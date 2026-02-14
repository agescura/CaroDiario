extension ApplicationClient {
  public static var noop: ApplicationClient {
    ApplicationClient(
      open: { _, _ in },
      openSettings: { },
      setAlternateIconName: { _ in },
      setUserInterfaceStyle: { _ in },
      share: { _, _ in }
    )
  }
}
