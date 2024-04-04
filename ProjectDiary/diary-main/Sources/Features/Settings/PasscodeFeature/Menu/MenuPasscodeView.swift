import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper
import Models

public struct MenuPasscodeView: View {
  let store: StoreOf<Menu>
  
  public init(
    store: StoreOf<Menu>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section(
          footer: Text("Passcode.Activate.Message".localized)
        ) {
          Button(action: {
            viewStore.send(.actionSheetButtonTapped)
          }) {
            Text("Passcode.Turnoff".localized)
              .foregroundColor(.chambray)
          }
					.confirmationDialog(
						store: self.store.scope(state: \.$dialog, action: { .dialog($0) })
					)
        }
        
        Section(header: Text(""), footer: Text("")) {
          Toggle(
            isOn: viewStore.binding(
              get: \.faceIdEnabled,
              send: Menu.Action.toggleFaceId
            )
          ) {
            Text("Passcode.UnlockFaceId".localized(with: [viewStore.authenticationType.rawValue]))
              .foregroundColor(.chambray)
          }
          .toggleStyle(SwitchToggleStyle(tint: .chambray))
          
          Picker("",  selection: viewStore.binding(
            get: \.optionTimeForAskPasscode,
            send: Menu.Action.optionTimeForAskPasscode
          )) {
            ForEach(viewStore.listTimesForAskPasscode, id: \.self) { type in
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
            viewStore.send(.popToRoot)
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
