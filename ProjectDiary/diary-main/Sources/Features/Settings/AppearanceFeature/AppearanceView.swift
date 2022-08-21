//
//  AppearanceView.swift
//  
//
//  Created by Albert Gil Escura on 23/8/21.
//

import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import UIApplicationClient
import FeedbackGeneratorClient
import Styles
import EntriesFeature
import Views
import SwiftUIHelper
import Models

public struct AppearanceState: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var themeType: ThemeType
    public var iconAppType: IconAppType
    public var route: Route? {
        didSet {
            if case let .style(state) = self.route {
                self.styleType = state.styleType
            }
            if case let .layout(state) = self.route {
                self.layoutType = state.layoutType
            }
            if case let .theme(state) = self.route {
                self.themeType = state.themeType
            }
            if case let .iconApp(state) = self.route {
                self.iconAppType = state.iconAppType
            }
        }
    }
    
    public enum Route: Equatable {
        case style(StyleState)
        case layout(LayoutState)
        case iconApp(IconAppState)
        case theme(ThemeState)
    }
    var styleState: StyleState? {
        get {
            guard case let .style(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .style(newValue)
        }
    }
    var layoutState: LayoutState? {
        get {
            guard case let .layout(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .layout(newValue)
        }
    }
    var iconAppState: IconAppState? {
        get {
            guard case let .iconApp(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .iconApp(newValue)
        }
    }
    var themeState: ThemeState? {
        get {
            guard case let .theme(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .theme(newValue)
        }
    }
    
    public init(
        styleType: StyleType,
        layoutType: LayoutType,
        themeType: ThemeType,
        iconAppType: IconAppType,
        route: Route? = nil
    ) {
        self.styleType = styleType
        self.layoutType = layoutType
        self.themeType = themeType
        self.iconAppType = iconAppType
        self.route = route
    }
}

public enum AppearanceAction: Equatable {
    case styleAction(StyleAction)
    case navigateStyle(Bool)
    
    case layoutAction(LayoutAction)
    case navigateLayout(Bool)
    
    case iconAppAction(IconAppAction)
    case navigateIconApp(Bool)
    
    case themeAction(ThemeAction)
    case navigateTheme(Bool)
}

public struct AppearanceEnvironment {
    public let applicationClient: UIApplicationClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) async -> Void
    
    public init(
        applicationClient: UIApplicationClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) async -> Void
    ) {
        self.applicationClient = applicationClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let appearanceReducer: Reducer<
    AppearanceState,
    AppearanceAction,
    AppearanceEnvironment
> = .combine(
    styleReducer
        .optional()
        .pullback(
            state: \AppearanceState.styleState,
            action: /AppearanceAction.styleAction,
            environment: {
                StyleEnvironment(
                    feedbackGeneratorClient: $0.feedbackGeneratorClient
                )
            }
        ),
    layoutReducer
        .optional()
        .pullback(
            state: \AppearanceState.layoutState,
            action: /AppearanceAction.layoutAction,
            environment: {
                LayoutEnvironment(
                    feedbackGeneratorClient: $0.feedbackGeneratorClient
                )
            }
        ),
    iconAppReducer
        .optional()
        .pullback(
            state: \AppearanceState.iconAppState,
            action: /AppearanceAction.iconAppAction,
            environment: {
                IconAppEnvironment(
                    feedbackGeneratorClient: $0.feedbackGeneratorClient,
                    applicationClient: $0.applicationClient
                )
            }
        ),
    themeReducer
        .optional()
        .pullback(
            state: \AppearanceState.themeState,
            action: /AppearanceAction.themeAction,
            environment: {
                ThemeEnvironment(
                    feedbackGeneratorClient: $0.feedbackGeneratorClient,
                    setUserInterfaceStyle: $0.setUserInterfaceStyle
                )
            }
        ),
    
    .init { state, action, environment in
        switch action {
            
        case .themeAction:
            return .none
            
        case let .navigateTheme(value):
            state.route = value ? .theme(
                .init(
                    themeType: state.themeType,
                    entries: fakeEntries(with: state.styleType, layout: state.layoutType)
                )
            ) : nil
            return .none
            
        case .iconAppAction:
            return .none
            
        case let .navigateIconApp(value):
            state.route = value ? .iconApp(
                .init(iconAppType: state.iconAppType)
            ) : nil
            return .none
            
        case .styleAction:
            return .none
            
        case let .navigateStyle(value):
            state.route = value ? .style(
                .init(
                    styleType: state.styleType,
                    layoutType: state.layoutType,
                    entries: fakeEntries(with: state.styleType, layout: state.layoutType)
                )
            ) : nil
            return .none
            
        case .layoutAction:
            return .none
            
        case let .navigateLayout(value):
            state.route = value ? .layout(
                .init(
                    layoutType: state.layoutType,
                    styleType: state.styleType,
                    entries: fakeEntries(with: state.styleType, layout: state.layoutType)
                )
            ) : nil
            return .none
        }
    }
)

public struct AppearanceView: View {
    let store: Store<AppearanceState, AppearanceAction>
    
    public init(
        store: Store<AppearanceState, AppearanceAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Section {
                    NavigationLink(
                        route: viewStore.route,
                        case: /AppearanceState.Route.style,
                        onNavigate: { viewStore.send(.navigateStyle($0)) },
                        destination: { styleState in
                            StyleView(
                                store: self.store.scope(
                                    state: { _ in styleState },
                                    action: AppearanceAction.styleAction
                                )
                            )
                        },
                        label: {
                            StyleRowView(title: viewStore.styleType.rawValue.localized)
                        }
                    )
                    NavigationLink(
                        route: viewStore.route,
                        case: /AppearanceState.Route.layout,
                        onNavigate: { viewStore.send(.navigateLayout($0)) },
                        destination: { layoutState in
                            LayoutView(
                                store: self.store.scope(
                                    state: { _ in layoutState },
                                    action: AppearanceAction.layoutAction
                                )
                            )
                        },
                        label: {
                            LayoutRowView(title: viewStore.layoutType.rawValue.localized)
                        }
                    )
                    NavigationLink(
                        route: viewStore.route,
                        case: /AppearanceState.Route.theme,
                        onNavigate: { viewStore.send(.navigateTheme($0)) },
                        destination: { themeState in
                            ThemeView(
                                store: self.store.scope(
                                    state: { _ in themeState },
                                    action: AppearanceAction.themeAction
                                )
                            )
                        },
                        label: {
                            ThemeRowView(
                                iconName: viewStore.themeType.icon,
                                title: viewStore.themeType.rawValue.localized
                            )
                        }
                    )
                    NavigationLink(
                        route: viewStore.route,
                        case: /AppearanceState.Route.iconApp,
                        onNavigate: { viewStore.send(.navigateIconApp($0)) },
                        destination: { iconAppState in
                            IconAppView(
                                store: self.store.scope(
                                    state: { _ in iconAppState },
                                    action: AppearanceAction.iconAppAction
                                )
                            )
                        },
                        label: {
                            IconAppRowView(title: viewStore.iconAppType.rawValue.localized)
                        }
                    )
                }
            }
        }
        .navigationBarTitle("Settings.Appearance".localized)
    }
}
