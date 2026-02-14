import SwiftUI

public struct ShakeGeometryEffect: GeometryEffect {
  private let amount: CGFloat = 10
  private let shakesPerUnit = 3
  private let animatableData: CGFloat
  
  public init(animatableData: CGFloat) {
    self.animatableData = animatableData
  }
  
  public func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(
      CGAffineTransform(
        translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
        y: 0
      )
    )
  }
}
