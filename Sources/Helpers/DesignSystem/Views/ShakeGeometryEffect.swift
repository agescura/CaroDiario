//
//  ShakeGeometryEffect.swift  
//
//  Created by Albert Gil Escura on 19/7/21.
//

import SwiftUI

public struct ShakeGeometryEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    public var animatableData: CGFloat
    
    public init(animatableData: CGFloat) {
        self.animatableData = animatableData
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
