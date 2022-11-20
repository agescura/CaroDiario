import ComposableArchitecture
import SwiftUI
import Styles
import EntriesFeature
import FeedbackGeneratorClient
import Models

public struct LayoutState: Equatable {
    public var layoutType: LayoutType
    public var styleType: StyleType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public init(
        layoutType: LayoutType,
        styleType: StyleType,
        entries: IdentifiedArrayOf<DayEntriesRowState>
    ) {
        self.layoutType = layoutType
        self.styleType = styleType
        self.entries = entries
    }
}

public enum LayoutAction: Equatable {
    case layoutChanged(LayoutType)
    case entries(id: UUID, action: DayEntriesRowAction)
}

public struct LayoutEnvironment {
    public var feedbackGeneratorClient: FeedbackGeneratorClient
    
    public init(
        feedbackGeneratorClient: FeedbackGeneratorClient
    ) {
        self.feedbackGeneratorClient = feedbackGeneratorClient
    }
}

public let layoutReducer: Reducer<
    LayoutState,
    LayoutAction,
    LayoutEnvironment
> = .combine(
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \LayoutState.entries,
            action: /LayoutAction.entries,
            environment: { _ in
                EntriesEnvironment(
                    fileClient: .noop,
                    userDefaultsClient: .noop,
                    avCaptureDeviceClient: .noop,
                    applicationClient: .noop,
                    avAudioSessionClient: .noop,
                    avAudioPlayerClient: .noop,
                    avAudioRecorderClient: .noop,
                    avAssetClient: .noop,
                    mainQueue: .immediate,
                    backgroundQueue: .immediate,
                    date: Date.init,
                    uuid: UUID.init
                )
            }
        ),
        .init { state, action, environment in
            switch action {
                
            case let .layoutChanged(appearanceChanged):
                state.layoutType = appearanceChanged
                state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
                
                return .fireAndForget {
                    await environment.feedbackGeneratorClient.selectionChanged()
                }
                
            case .entries:
                return .none
            }
        }
)

public struct LayoutView: View {
    let store: Store<LayoutState, LayoutAction>
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            
            VStack(alignment: .leading, spacing: 16) {
                
                Picker("",  selection: viewStore.binding(
                    get: \.layoutType,
                    send: LayoutAction.layoutChanged
                )) {
                    ForEach(LayoutType.allCases, id: \.self) { type in
                        Text(type.rawValue.localized)
                            .foregroundColor(.berryRed)
                            .adaptiveFont(.latoRegular, size: 10)
                    }
                }
                .frame(height: 60)
                .pickerStyle(SegmentedPickerStyle())
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEachStore(
                            store.scope(
                                state: \.entries,
                                action: LayoutAction.entries(id:action:)),
                            content: DayEntriesRowView.init(store:)
                        )
                    }
                    .accentColor(.chambray)
                    .animation(.default, value: UUID())
                    .disabled(true)
                }
                
                Spacer()
            }
            .padding(16)
            .navigationBarTitle("Settings.Layout".localized)
        }
    }
}
