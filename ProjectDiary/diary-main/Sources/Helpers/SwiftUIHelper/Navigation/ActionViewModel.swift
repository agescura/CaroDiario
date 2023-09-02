import Foundation
import SwiftUI

public struct ActionViewModel<Action>: Equatable {
    let title: String
    let message: String?
    let buttons: [ActionViewModel.Button<Action>]
    
    public init(
        _ title: String,
        message: String? = nil,
        buttons: [ActionViewModel.Button<Action>]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
    
    public init(
        message: String? = nil,
        buttons: [ActionViewModel.Button<Action>]
    ) {
        self.title = ""
        self.message = message
        self.buttons = buttons
    }
    
    public struct Button<Action>: Hashable {
        let id = UUID()
        let title: String
        let role: ButtonRole?
        let action: Action
        
        public init(
            _ title: String,
            role: ButtonRole? = nil,
            action: Action
        ) {
            self.title = title
            self.role = role
            self.action = action
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
