//
//  StyleType.swift
//  Models
//
//  Created by Albert Gil Escura on 4/7/21.
//

import Foundation

public enum StyleType: String, CaseIterable, Identifiable {
    case rectangle = "Style.Rectangle"
    case rounded = "Style.Rounded"
    
    public var id: String { self.rawValue }
}
