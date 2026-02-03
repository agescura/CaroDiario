extension ApplicationClient {
  public static var noop: Self {
    Self(
      open: { _, _ in },
    )
  }
}
