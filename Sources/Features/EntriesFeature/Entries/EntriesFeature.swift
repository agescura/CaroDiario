import ApplicationClient
import ComposableArchitecture
import DesignSystem
import EntryDetailFeature
import Foundation
import Models
import SQLiteData

extension EntriesFeature.State: Sendable {}
extension EntriesFeature.Path.State: Equatable, Sendable {}
extension EntriesFeature.Path.Action: Equatable {}
extension EntriesFeature.Destination.State: Equatable, Sendable {}
extension EntriesFeature.Destination.Action: Equatable {}

extension Asset.TableColumns {
  var imagesCount: some QueryExpression<Int> {
    id.count(filter: format.eq(Format.image))
  }
  
  var videosCount: some QueryExpression<Int> {
    id.count(filter: format.eq(Format.video))
  }
}

@Reducer
public struct EntriesFeature {
	public init() {}

	@Reducer
	public enum Path {
		case detail(EntryDetailFeature)
	}
  
  @Reducer
  public enum Destination {
    case alert(AlertState<Alert>)
    case add(EntryDetailFeature)
    
    public enum Alert: Equatable, Sendable {
      case discard
    }
  }
	
	@ObservableState
	public struct State: Equatable {
    @Presents public var destination: Destination.State?
    public var path: StackState<Path.State>
    @FetchAll var dayEntriesRows: [GroupedEntries]
    public var expandedDayEntries: Set<Date> = []
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    private var dayEntriesQuery: some StructuredQueries.Statement<GroupedEntries> {
      With {
        Entry
          .group(by: \.id)
          .where { !$0.isDraft }
          .leftJoin(EntryAsset.all) { $1.entryID.eq($0.id) }
          .leftJoin(Asset.all) { $1.assetID.eq($2.id) }
          .select { entry, entryAsset, asset in
            EntryModel.Columns(
              id: entry.id,
              createdAt: entry.createdAt,
              dayDate: entry.dayDate,
              imagesCount: asset.imagesCount ?? 0,
              message: entry.message,
              updatedAt: entry.updatedAt,
              videosCount: asset.videosCount ?? 0
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
      destination: Destination.State? = nil,
			path: StackState<Path.State> = StackState<Path.State>()
		) {
      self.destination = destination
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
	
	public enum Action: ViewAction, Equatable {
    case destination(PresentationAction<EntriesFeature.Destination.Action>)
    case path(StackActionOf<Path>)
    case view(View)
    
    public enum View: Equatable {
      case addEntryButtonTapped
      case dayEntryButtonTapped(Date)
      case dismissButtonTapped
      case entryButtonTapped(EntryModel)
    }
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.continuousClock) var clock
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.uuid) var uuid
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
      switch action {
      case.destination(.presented(.alert(.discard))):
        state.destination = nil
        state.path = StackState()
        return .none
      case .destination:
        return .none
      case .path:
        return .none
      case let .view(action):
        switch action {
        case .addEntryButtonTapped:
          state.destination = .add(
            EntryDetailFeature.State(
              entry: Entry.Draft(createdAt: Date(), isDraft: true, updatedAt: Date(), message: "")
            )
          )
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
          state.destination = nil
          state.path = StackState()
          return .none
        case let .entryButtonTapped(entry):
          let draft = Entry.Draft(
            Entry(id: entry.id, createdAt: entry.createdAt, isDraft: false, updatedAt: entry.updatedAt, message: entry.message)
          )
          state.path.append(.detail(EntryDetailFeature.State(entry: draft)))
          return .none
        }
      }
		}
    .ifLet(\.$destination, action: \.destination)
		.forEach(\.path, action: \.path)
	}
}

extension AlertState where Action == EntriesFeature.Destination.Alert {
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
