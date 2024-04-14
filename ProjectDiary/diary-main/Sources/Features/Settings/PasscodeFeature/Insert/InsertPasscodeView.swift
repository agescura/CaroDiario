import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper

public struct InsertView: View {
	@Perception.Bindable var store: StoreOf<InsertFeature>
  
  public init(
    store: StoreOf<InsertFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      VStack(spacing: 8) {
        Spacer()
        VStack(spacing: 32) {
					Text(self.store.step.title)
          HStack {
            ForEach(0..<self.store.maxNumbersCode, id: \.self) { iterator in
							WithPerceptionTracking {
								Image(self.store.code.count > iterator ? .circleFill : .circle)
							}
            }
          }
          if self.store.codeNotMatched {
            Text("Passcode.Different".localized)
              .foregroundColor(.berryRed)
          }
          Spacer()
        }
        CustomTextField(
					text: self.$store.code.sending(\.update),
          isFirstResponder: true
        )
        .frame(width: 300, height: 50)
        .opacity(0.0)
        
        Spacer()
        SecondaryButtonView(
          label: { Text("Passcode.Dismiss".localized) }
        ) {
					self.store.send(.popButtonTapped)
        }
      }
      .padding(16)
      .navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(
        leading: Button(
					action: { self.store.send(.popButtonTapped) }
        ) {
          HStack { Image(.chevronLeft) }
        }
      )
    }
  }
}
