import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles

public struct ThemeView: View {
    let store: StoreOf<Theme>
    
    public var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }
        ) { viewStore in
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("OnBoarding.Theme.Title".localized)
                            .adaptiveFont(.latoBold, size: 24)
                            .foregroundColor(.adaptiveBlack)
                        Text("OnBoarding.Style.Message".localized)
                            .foregroundColor(.adaptiveBlack)
                            .adaptiveFont(.latoRegular, size: 10)
                        Picker("",  selection: viewStore.binding(
                            get: \.themeType,
                            send: Theme.Action.themeChanged
                        )) {
                            ForEach(ThemeType.allCases, id: \.self) { type in
                                Text(type.rawValue.localized)
                                    .foregroundColor(.berryRed)
                                    .adaptiveFont(.latoRegular, size: 10)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEachStore(
                                store.scope(
                                    state: \.entries,
                                    action: Theme.Action.entries(id:action:)),
                                content: DayEntriesRowView.init(store:)
                            )
                        }
                        .accentColor(.chambray)
                        .animation(.default, value: UUID())
                        .disabled(true)
                        .frame(minHeight: 200)
                    }
                }
                
                PrimaryButtonView(
                    label: {
                        Text(viewStore.isAppClip ? "Instalar en App Store" : "OnBoarding.Start".localized)
                            .adaptiveFont(.latoRegular, size: 16)
                    }) {
                        viewStore.send(.startButtonTapped)
                    }
                    .padding(.horizontal, 16)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
