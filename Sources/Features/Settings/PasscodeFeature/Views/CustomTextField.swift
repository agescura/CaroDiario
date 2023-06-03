import Combine
import Dependencies
import SwiftUI

struct CustomTextField: UIViewRepresentable {
	class Coordinator: NSObject, UITextFieldDelegate {
		
		@Binding private var text: String
		var didBecomeFirstResponder = false
		var cancellable: Cancellable?

		init(text: Binding<String>) {
			_text = text
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			text = textField.text ?? ""
		}
		
	}
	
	@Binding var text: String
	var isFirstResponder: Bool = false
	@Dependency(\.mainQueue) private var mainQueue
	
	func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
		let textField = UITextField(frame: .zero)
		textField.keyboardType = .numberPad
		textField.delegate = context.coordinator
		return textField
	}
	
	func makeCoordinator() -> CustomTextField.Coordinator {
		Coordinator(text: $text)
	}
	
	func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
		uiView.text = text
		if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
			context.coordinator.cancellable = Just(())
				.delay(for: .seconds(0.5), scheduler: self.mainQueue)
				.sink {
					uiView.becomeFirstResponder()
				}
			context.coordinator.didBecomeFirstResponder = true
		}
	}
}
