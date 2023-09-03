import ComposableArchitecture
import SwiftUI
import EntriesFeature
import CoreDataClient
import FileClient
import UserDefaultsClient
import AVCaptureDeviceClient
import UIApplicationClient
import AVAudioPlayerClient
import AVAudioSessionClient
import AVAudioRecorderClient
import EntryDetailFeature
import Models
import AVAssetClient

public struct AttachmentSearch: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var type: AttachmentSearchType
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var entryDetailState: EntryDetailFeature.State?
		public var navigateEntryDetail = false
		public var entryDetailSelected: Entry?
		
		public var entriesCount: Int {
			entries.map(\.dayEntries.entries.count).reduce(0, +)
		}
	}
	
	public enum Action: Equatable {
		case entries(id: UUID, action: DayEntriesRow.Action)
		case remove(Entry)
		case entryDetailAction(EntryDetailFeature.Action)
		case navigateEntryDetail(Bool)
	}
	
	@Dependency(\.fileClient) private var fileClient
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: /Action.entries) {
				DayEntriesRow()
			}
			.ifLet(\.entryDetailState, action: /Action.entryDetailAction) {
				EntryDetailFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
				state.entryDetailSelected = entry
				return .send(.navigateEntryDetail(true))
				
			case .entries:
				return .none
				
			case .remove:
				return .none
				
			case let .navigateEntryDetail(value):
				guard let entry = state.entryDetailSelected else { return .none }
				state.navigateEntryDetail = value
				state.entryDetailState = value ? .init(entry: entry) : nil
				if value == false {
					state.entryDetailSelected = nil
				}
				return .none
				
			case let .entryDetailAction(.remove(entry)):
				return .run { send in
					await self.fileClient.removeAttachments(entry.attachments.urls)
					await send(.remove(entry))
					await send(.navigateEntryDetail(false))
				}
				
			case .entryDetailAction:
				return .none
		}
	}
}

public enum AttachmentSearchType: String {
	case images
	case videos
	case audios
}

extension AttachmentSearchType {
	var title: String {
		switch self {
			case .images:
				return "Settings.Attachment.Image".localized
			case .videos:
				return "Settings.Attachment.Video".localized
			case .audios:
				return "Settings.Attachment.Audio".localized
		}
	}
}

public struct AttachmentSearchView: View {
	private let store: StoreOf<AttachmentSearch>
	
	public init(
		store: StoreOf<AttachmentSearch>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ScrollView(.vertical) {
				VStack(alignment: .leading, spacing: 16) {
					
					if !viewStore.entries.isEmpty {
						Text("\("Settings.Results".localized) \(viewStore.entriesCount)")
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 10)
							.padding(.leading)
					} else {
						Text("Search.Empty".localized)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 10)
							.padding(.leading)
					}
					
					ZStack {
						LazyVStack(alignment: .leading, spacing: 8) {
							ForEachStore(
								store.scope(
									state: \.entries,
									action: AttachmentSearch.Action.entries(id:action:)),
								content: DayEntriesRowView.init(store:)
							)
						}
						
						NavigationLink(
							"", destination: IfLetStore(
								store.scope(
									state: \.entryDetailState,
									action: AttachmentSearch.Action.entryDetailAction
								),
								then: EntryDetailView.init(store:)
							),
							isActive: viewStore.binding(
								get: \.navigateEntryDetail,
								send: AttachmentSearch.Action.navigateEntryDetail)
						)
					}
				}
				.padding(.top, 16)
			}
			.navigationBarTitle(viewStore.type.title, displayMode: .inline)
		}
	}
}
