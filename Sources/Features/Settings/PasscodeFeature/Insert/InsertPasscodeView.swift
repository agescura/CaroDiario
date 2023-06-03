import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper

public struct InsertView: View {
	let store: StoreOf<InsertFeature>
	
	private struct ViewState: Equatable {
		let step: InsertFeature.State.Step
		let maxNumbersCode: Int
		let code: String
		let codeNotMatched: Bool
		
		init(
			state: InsertFeature.State
		) {
			self.step = state.step
			self.maxNumbersCode = state.maxNumbersCode
			self.code = state.code
			self.codeNotMatched = state.codeNotMatched
		}
	}
	
	public init(
		store: StoreOf<InsertFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			VStack(spacing: 8) {
				Spacer()
				VStack(spacing: 32) {
					Text(viewStore.step.title)
					HStack {
						ForEach(0..<viewStore.maxNumbersCode, id: \.self) { iterator in
							Image(viewStore.code.count > iterator ? .circleFill : .circle)
						}
					}
					if viewStore.codeNotMatched {
						Text("Passcode.Different".localized)
							.foregroundColor(.berryRed)
					}
					Spacer()
				}
				CustomTextField(
					text: viewStore.binding(
						get: \.code,
						send: InsertFeature.Action.update
					),
					isFirstResponder: true
				)
				.frame(width: 300, height: 50)
				.opacity(0.0)
				
				Spacer()
				SecondaryButtonView(
					label: { Text("Passcode.Dismiss".localized) }
				) {
					viewStore.send(.popToRoot)
				}
				
				NavigationLinkStore(
					self.store.scope(
						state: \.$menu,
						action: InsertFeature.Action.menu
					),
					destination: MenuPasscodeView.init,
					label: EmptyView.init
				)
			}
			.padding(16)
			.navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						viewStore.send(.popToRoot)
					} label: {
						Image(.chevronLeft)
					}
				}
			}
		}
	}
}
