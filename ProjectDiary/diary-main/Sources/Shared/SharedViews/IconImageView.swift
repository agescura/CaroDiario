//
//  IconImageView.swift  
//
//  Created by Albert Gil Escura on 10/9/21.
//

import SwiftUI

public struct IconImageView: View {
    let systemName: String
    let foregroundColor: Color
    let size: CGFloat
    
    public init(
        systemName: String,
        foregroundColor: Color,
        size: CGFloat = 24
    ) {
        self.systemName = systemName
        self.foregroundColor = foregroundColor
        self.size = size
    }
    
    public var body: some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(foregroundColor)
    }
}
