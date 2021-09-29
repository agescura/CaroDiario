//
//  Interface.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import ComposableArchitecture
import SharedModels

public struct PDFKitClient {
    public var generatePDF: ([[Entry]], Date) -> Effect<Data, Never>
    
    public init(
        generatePDF: @escaping ([[Entry]], Date) -> Effect<Data, Never>
    ) {
        self.generatePDF = generatePDF
    }
}
