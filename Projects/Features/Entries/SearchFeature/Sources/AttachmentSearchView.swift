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

@Reducer
public struct AttachmentSearch {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var type: AttachmentSearchType
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		@Presents public var entryDetailState: EntryDetailFeature.State?
		
		public var entriesCount: Int {
			entries.map(\.dayEntries.entries.count).reduce(0, +)
		}
	}
	
	public enum Action: Equatable {
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case remove(Entry)
		case entryDetailAction(PresentationAction<EntryDetailFeature.Action>)
	}
	
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.mainQueue) private var mainQueue
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: \.entries) {
				DayEntriesRow()
			}
			.ifLet(\.$entryDetailState, action: \.entryDetailAction) {
				EntryDetailFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .entries(.element(id: _, action: .dayEntry(.navigateDetail(entry)))):
				state.entryDetailState = EntryDetailFeature.State(entry: entry)
				return .none
				
			case .entries:
				return .none
				
			case .remove:
				return .none
				
			case let .entryDetailAction(.presented(.alert(.presented(.remove(entry))))):
				state.entryDetailState = nil
				return .run { send in
					_ = await self.fileClient.removeAttachments(entry.attachments.urls)
					await send(.remove(entry))
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
	@Bindable var store: StoreOf<AttachmentSearch>
	
	public var body: some View {
		ScrollView(.vertical) {
			VStack(alignment: .leading, spacing: 16) {
				
				if !store.entries.isEmpty {
					Text("\("Settings.Results".localized) \(store.entriesCount)")
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
						ForEach(
							store.scope(
								state: \.entries,
								action: \.entries
							),
							id: \.state.id
						) { store in
							DayEntriesRowView(store: store)
						}
					}
				}
			}
			.padding(.top, 16)
		}
		.navigationBarTitle(store.type.title, displayMode: .inline)
		.navigationDestination(
			item: $store.scope(
				state: \.entryDetailState,
				action: \.entryDetailAction
			)
		) { store in
			EntryDetailView(store: store)
		}
	}
}
