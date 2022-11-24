import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper

public struct AboutView: View {
  let store: StoreOf<About>
  
  public init(
    store: StoreOf<About>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        Form {
          Section {
            HStack(spacing: 16) {
              Text("Settings.Version".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
              Spacer()
              Text("1.7")
                .foregroundColor(.adaptiveGray)
                .adaptiveFont(.latoRegular, size: 12)
            }
          }
          
          Section {
            HStack(spacing: 16) {
              
              Text("Settings.ReportBug".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
              Spacer()
              Image(.chevronRight)
                .foregroundColor(.adaptiveGray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
              viewStore.send(.emailOptionSheetButtonTapped)
            }
            .confirmationDialog(
              store.scope(state: \.emailOptionSheet),
              dismiss: .dismissEmailOptionSheet
            )
          }
        }
      }
    }
    .navigationBarTitle("Settings.About".localized)
  }
}
