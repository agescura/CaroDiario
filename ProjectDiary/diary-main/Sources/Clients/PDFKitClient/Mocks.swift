//
//  Mocks.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import Foundation

extension PDFKitClient {
    public static let noop = Self(
        generatePDF: { _, _ in .fireAndForget {} }
    )
}
