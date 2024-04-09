import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper
import Models

public struct MenuPasscodeView: View {
	@Perception.Bindable var store: StoreOf<MenuFeature>
  
  public init(
    store: StoreOf<MenuFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      Form {
        Section(
          footer: Text("Passcode.Activate.Message".localized)
        ) {
          Button(action: {
						self.store.send(.actionSheetButtonTapped)
          }) {
            Text("Passcode.Turnoff".localized)
              .foregroundColor(.chambray)
          }
					.confirmationDialog(
						store: self.store.scope(state: \.$dialog, action: \.dialog)
					)
        }
        
        Section(header: Text(""), footer: Text("")) {
          Toggle(
						isOn: self.$store.userSettings.faceIdEnabled.sending(\.toggleFaceId)
          ) {
						Text("Passcode.UnlockFaceId".localized(with: [self.store.authenticationType.rawValue]))
              .foregroundColor(.chambray)
          }
          .toggleStyle(SwitchToggleStyle(tint: .chambray))
          
					Picker(
						"",
						selection: self.$store.userSettings.timeForAskPasscode.sending(\.optionTimeForAskPasscode)
					) {
						ForEach(self.store.listTimesForAskPasscode, id: \.self) { type in
              Text(type.rawValue)
                .adaptiveFont(.latoRegular, size: 12)
            }
          }
          .overlay(
            HStack(spacing: 16) {
              Text("Passcode.Autolock".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
              Spacer()
            }
          )
        }
      }
      .navigationBarItems(
        leading: Button(
          action: {
						self.store.send(.popToRoot)
          }
        ) {
          Image(.chevronRight)
        }
      )
    }
    .navigationBarTitle("Passcode.Title".localized)
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
	MenuPasscodeView(
		store: Store(
			initialState: MenuFeature.State(
				authenticationType: .faceId,
				optionTimeForAskPasscode: 5
			),
			reducer: { MenuFeature() }
		)
	)
}
