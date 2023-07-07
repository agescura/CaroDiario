import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper

public struct InsertPasscodeView: View {
	let store: StoreOf<InsertPasscodeFeature>
	
	private struct ViewState: Equatable {
		let code: String
		let codeNotMatched: Bool
		let maxNumbersCode: Int
		let step: InsertPasscodeFeature.State.Step
		
		init(
			state: InsertPasscodeFeature.State
		) {
			self.code = state.code
			self.codeNotMatched = state.codeNotMatched
			self.maxNumbersCode = state.maxNumbersCode
			self.step = state.step
		}
	}
	
	public init(
		store: StoreOf<InsertPasscodeFeature>
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
						send: InsertPasscodeFeature.Action.update
					),
					isFirstResponder: true
				)
				.frame(width: 300, height: 50)
				.opacity(0.0)
				
				Spacer()
				SecondaryButtonView(
					label: { Text("Passcode.Dismiss".localized) }
				) {
					viewStore.send(.popToRootButtonTapped)
				}
				
				NavigationLinkStore(
					self.store.scope(
						state: \.$menu,
						action: InsertPasscodeFeature.Action.menu
					),
					destination: MenuPasscodeView.init
				)
			}
			.padding(16)
			.navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						viewStore.send(.popToRootButtonTapped)
					} label: {
						HStack { Image(.chevronLeft) }
					}
				}
			}
		}
	}
}
