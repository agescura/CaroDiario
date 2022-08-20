//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import CasePaths

extension NavigationLink {
    public init<Enum, Case, WrappedDestination>(
        route optionalValue: Enum?,
        case casePath: CasePath<Enum, Case>,
        onNavigate: @escaping (Bool) -> Void,
        @ViewBuilder destination: @escaping (Case) -> WrappedDestination,
        @ViewBuilder label: @escaping () -> Label
    ) where Destination == WrappedDestination? {
        let pattern = Binding.constant(optionalValue).case(casePath)

        self.init(
            isActive: Binding(
                get: { pattern.wrappedValue != nil },
                set: { isPresented in
                    onNavigate(isPresented)
                }
            ),
            destination: {
                if let value = pattern.wrappedValue {
                    destination(value)
                }
            },
            label: label
        )
    }
}

extension Binding {
    func `case`<Enum, Case>(
        _ casePath: CasePath<Enum, Case>
    ) -> Binding<Case?> where Value == Enum? {
        Binding<Case?>(
            get: {
                guard
                    let wrappedValue = self.wrappedValue,
                    let `case` = casePath.extract(from: wrappedValue)
                else { return nil }
                return `case`
            },
            set: { `case` in
                if let `case` = `case` {
                    self.wrappedValue = casePath.embed(`case`)
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}
