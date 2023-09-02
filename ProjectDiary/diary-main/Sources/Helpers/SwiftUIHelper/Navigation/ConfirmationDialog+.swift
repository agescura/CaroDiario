import Foundation
import SwiftUI
import CasePaths

extension View {
    public func confirmationDialog<Enum, Case, Action>(
        route optionalValue: Enum?,
        case casePath: CasePath<Enum, Case>,
        titleVisibility: Visibility = .automatic,
        send: @escaping (Action) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let pattern = Binding.constant(optionalValue).case(casePath)
        let presenting = pattern.wrappedValue as? ActionViewModel<Action>
        
        return self.confirmationDialog(
            Text(presenting?.title ?? ""),
            isPresented: .init(
                get: { pattern.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        onDismiss?()
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: presenting,
            actions: { (alertViewModel: ActionViewModel<Action>) in
                ForEach(alertViewModel.buttons, id: \.self) { button in
                    Button(
                        button.title,
                        role: button.role
                    ) {
                        send(button.action)
                    }
                }
            },
            message: {
                if let message = $0.message {
                    Text(message)
                }
            }
        )
    }
}
