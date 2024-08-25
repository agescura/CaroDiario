import ComposableArchitecture
import Styles
import SwiftUI
import SwiftUIHelper
import Views

@ViewAction(for: InsertFeature.self)
public struct InsertView: View {
	@Bindable public var store: StoreOf<InsertFeature>
	@FocusState private var isFocused: Bool
	
	public init(
		store: StoreOf<InsertFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack(spacing: 8) {
			Spacer()
			VStack(spacing: 32) {
				Text(store.step.title)
					.textStyle(.title)
				HStack {
					ForEach(0..<store.maxNumbersCode, id: \.self) { iterator in
						Image(store.code.count > iterator ? .circleFill : .circle)
					}
				}
				if store.codeNotMatched {
					Text("Passcode.Different".localized)
						.textStyle(.error)
				}
				Spacer()
			}
			TextField("", text: $store.code.sending(\.update).removeDuplicates())
				.keyboardType(.numberPad)
				.focused($isFocused)
				.opacity(0.0)
			
			Spacer()
			Button("Passcode.Dismiss".localized) {
				send(.popButtonTapped)
			}
			.buttonStyle(.primary)
		}
		.padding(16)
		.navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(
			leading: Button(
				action: { send(.popButtonTapped) }
			) {
				HStack { Image(.chevronLeft) }
			}
		)
		.onAppear { isFocused = true }
	}
}

#Preview {
	InsertView(
		store: Store(
			initialState: InsertFeature.State(),
			reducer: { InsertFeature() }
		)
	)
}

extension Binding where Value: Equatable {
	func removeDuplicates() -> Self {
		.init(
			get: { self.wrappedValue },
			set: { newValue, transaction in
				guard newValue != self.wrappedValue else { return }
				self.transaction(transaction).wrappedValue = newValue
			}
		)
	}
}
