//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 19/3/22.
//

import Foundation

public enum Localizable: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case catalan = "ca"
    
    public var id: String {
        rawValue
    }
    
    public var localizable: String {
        switch self {
        case .english:
            return "Settings.English"
        case .spanish:
            return "Settings.Spanish"
        case .catalan:
            return "Settings.Catalan"
        }
    }
}
