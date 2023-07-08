import ComposableArchitecture
import EntriesFeature
import Foundation
import Models
import TCAHelpers

public struct AppearanceFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var appearanceSettings: AppearanceSettings
		@PresentationState public var destination: Destination.State?
		
		public var id: Int { 1 }
		
		public init(
			appearanceSettings: AppearanceSettings,
			destination: Destination.State? = nil
		) {
			self.appearanceSettings = appearanceSettings
			self.destination = destination
		}
	}
	
	public enum Action: Equatable {
		case destination(PresentationAction<Destination.Action>)
		case iconAppButtonTapped
		case layoutButtonTapped
		case styleButtonTapped
		case themeButtonTapped
	}
	
	public struct Destination: ReducerProtocol {
		public init() {}
		
		public enum State: Equatable, Identifiable {
			case iconApp(IconAppFeature.State)
			case layout(LayoutFeature.State)
			case style(StyleFeature.State)
			case theme(ThemeFeature.State)
			public var id: AnyHashable {
				switch self {
					case let .iconApp(state):
						return state.id
					case let .layout(state):
						return state.id
					case let .style(state):
						return state.id
					case let .theme(state):
						return state.id
				}
			}
		}
		public enum Action: Equatable {
			case iconApp(IconAppFeature.Action)
			case layout(LayoutFeature.Action)
			case style(StyleFeature.Action)
			case theme(ThemeFeature.Action)
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.iconApp, action: /Action.iconApp) {
				IconAppFeature()
			}
			Scope(state: /State.layout, action: /Action.layout) {
				LayoutFeature()
			}
			Scope(state: /State.style, action: /Action.style) {
				StyleFeature()
			}
			Scope(state: /State.theme, action: /Action.theme) {
				ThemeFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .destination(.dismiss):
					switch state.destination {
						case let .iconApp(iconAppState):
							state.appearanceSettings.iconAppType = iconAppState.iconAppType
						case let .layout(layoutState):
							state.appearanceSettings.layoutType = layoutState.layoutType
						case let .style(styleState):
							state.appearanceSettings.styleType = styleState.styleType
						case let .theme(themeState):
							state.appearanceSettings.themeType = themeState.themeType
						case .none:
							return .none
					}
					return .none
					
				case .destination:
					return .none
					
				case .iconAppButtonTapped:
					state.destination = .iconApp(
						IconAppFeature.State(iconAppType: state.appearanceSettings.iconAppType)
					)
					return .none
					
				case .layoutButtonTapped:
					state.destination = .layout(
						LayoutFeature.State(
							layoutType: state.appearanceSettings.layoutType,
							styleType: state.appearanceSettings.styleType,
							entries: fakeEntries(with: state.appearanceSettings.styleType, layout: state.appearanceSettings.layoutType)
						)
					)
					return .none
					
				case .styleButtonTapped:
					state.destination = .style(
						StyleFeature.State(
							styleType: state.appearanceSettings.styleType,
							layoutType: state.appearanceSettings.layoutType,
							entries: fakeEntries(with: state.appearanceSettings.styleType, layout: state.appearanceSettings.layoutType)
						)
					)
					return .none
					
				case .themeButtonTapped:
					state.destination = .theme(
						ThemeFeature.State(
							themeType: state.appearanceSettings.themeType,
							entries: fakeEntries(with: state.appearanceSettings.styleType, layout: state.appearanceSettings.layoutType)
						)
					)
					return .none
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}
