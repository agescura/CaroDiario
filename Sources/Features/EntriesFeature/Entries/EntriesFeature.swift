import ApplicationClient
//import AddEntryFeature
import ComposableArchitecture
import DesignSystem
import EntryDetailFeature
import Foundation
import Models
import SQLiteData

extension EntriesFeature.State: Sendable {}
extension EntriesFeature.Path.State: Sendable {}

@Reducer
public struct EntriesFeature {
	public init() {}
	
	@Reducer(state: .equatable, action: .equatable)
	public enum Path {
		case detail(EntryDetailFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
    @Presents public var alert: AlertState<Action.Alert>?
		@Presents public var add: EntryDetailFeature.State?
    public var path: StackState<Path.State>
    @FetchAll var dayEntriesRows: [GroupedEntries]
    public var expandedDayEntries: Set<Date> = []
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    private var dayEntriesQuery: some StructuredQueries.Statement<GroupedEntries> {
      With {
        Entry
          .select {
            EntryModel.Columns(
              id: $0.id,
              createdAt: $0.createdAt,
              dayDate: $0.dayDate,
              message: $0.message,
              updatedAt: $0.updatedAt
            )
          }
      } query: {
        EntryModel
          .group(by: \.dayDate)
          .order {
            $0.dayDate.desc()
          }
          .select {
            GroupedEntries.Columns(
              date: $0.dayDate,
              isExpanded: expandedDayEntries.contains($0.dayDate),
              entries: $0.jsonGroupArray(order: $0.updatedAt.desc())
            )
          }
      }
    }
		
		public init(
			path: StackState<Path.State> = StackState<Path.State>()
		) {
			self.path = path
      _dayEntriesRows = FetchAll(
        dayEntriesQuery,
        animation: .custom
      )
		}
    
    func updateQuery() async {
      _ = await withErrorReporting {
        try await $dayEntriesRows.load(dayEntriesQuery, animation: .custom)
      }
    }
	}
	
	public enum Action: Equatable {
    case alert(PresentationAction<Alert>)
    case add(PresentationAction<EntryDetailFeature.Action>)
    case addEntryButtonTapped
    case dayEntryButtonTapped(Date)
    case dismissButtonTapped
    case entryButtonTapped(EntryModel)
    case path(StackActionOf<Path>)
    case presentAddEntryCompleted
    case remove(Entry)
    case task
    
    public enum Alert: Equatable, Sendable {
      case discard
    }
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.continuousClock) var clock
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.uuid) var uuid
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
      switch action {
      case let .alert(action):
        switch action {
        case .presented(.discard):
          state.add = nil
          state.path = StackState()
          return .none
        default:
          return .none
        }
      case .addEntryButtonTapped:
        state.add = EntryDetailFeature.State(entry: Entry.Draft(createdAt: Date(), updatedAt: Date(), message: ""))
        return .none
      case let .dayEntryButtonTapped(day):
        if state.expandedDayEntries.contains(day) {
          state.expandedDayEntries.remove(day)
        } else {
          state.expandedDayEntries.insert(day)
        }
        return .run { [state] _ in
          await state.updateQuery()
        }
      case .dismissButtonTapped:
        if state.add?.entry != state.add?.entryModified || state.path.first?.detail?.entry != state.path.first?.detail?.entryModified {
          state.alert = .alert
          return .none
        }
        state.add = nil
        state.path = StackState()
        return .none
      case let .entryButtonTapped(entry):
        let draft = Entry.Draft(Entry(id: entry.id, createdAt: entry.createdAt, updatedAt: entry.updatedAt, message: entry.message))
        state.path.append(.detail(EntryDetailFeature.State(entry: draft)))
        return .none
      case .path:
        return .none
      default:
        return .none
      }
		}
    .ifLet(\.$alert, action: \.alert)
		.ifLet(\.$add, action: \.add) {
			EntryDetailFeature()
		}
		.forEach(\.path, action: \.path)
	}
}

extension AlertState where Action == EntriesFeature.Action.Alert {
  public static var alert: AlertState {
    AlertState {
      TextState("OnBoarding.Skip.Title".localized)
    } actions: {
      ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
      ButtonState(role: .destructive, action: .discard, label: { TextState("OnBoarding.Skip".localized) })
    } message: {
      TextState("OnBoarding.Skip.Alert".localized)
    }
  }
}
