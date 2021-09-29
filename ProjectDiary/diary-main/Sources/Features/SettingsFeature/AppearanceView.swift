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
import SharedStyles
import EntriesFeature
import SharedViews

public struct AppearanceState: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var themeType: ThemeType
    public var iconAppType: IconAppType
    
    public var styleState: StyleState?
    public var navigateStyle: Bool = false
    
    public var layoutState: LayoutState?
    public var navigateLayout: Bool = false
    
    public var iconAppState: IconAppState?
    public var navigateIconApp: Bool = false
    
    public var themeState: ThemeState?
    public var navigateTheme: Bool = false
}

public enum AppearanceAction: Equatable {
    case styleAction(StyleAction)
    case navigateStyle(Bool)
    
    case layoutAction(LayoutAction)
    case navigateLayout(Bool)
    
    case iconAppAction(IconAppAction)
    case navigateIconApp(Bool)
    case iconAlternateIconChanged
    
    case themeAction(ThemeAction)
    case navigateTheme(Bool)
}

public struct AppearanceEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let applicationClient: UIApplicationClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
}

public let appearanceReducer: Reducer<AppearanceState, AppearanceAction, AppearanceEnvironment> = .combine(

    styleReducer
        .optional()
        .pullback(
            state: \AppearanceState.styleState,
            action: /AppearanceAction.styleAction,
            environment: { StyleEnvironment(
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop)
            }
        ),
    
    layoutReducer
        .optional()
        .pullback(
            state: \AppearanceState.layoutState,
            action: /AppearanceAction.layoutAction,
            environment: { LayoutEnvironment(
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop)
            }
        ),
    
    iconAppReducer
        .optional()
        .pullback(
            state: \AppearanceState.iconAppState,
            action: /AppearanceAction.iconAppAction,
            environment: { IconAppEnvironment(
                feedbackGeneratorClient: $0.feedbackGeneratorClient)
            }
        ),
    
    themeReducer
        .optional()
        .pullback(
            state: \AppearanceState.themeState,
            action: /AppearanceAction.themeAction,
            environment: { ThemeEnvironment(
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case let.themeAction(.themeChanged(themeChanged)):
            state.themeType = themeChanged
            return .merge(
                environment.setUserInterfaceStyle(themeChanged.userInterfaceStyle)
                    .fireAndForget(),
                environment.userDefaultsClient.set(themeType: themeChanged)
                    .fireAndForget()
            )
            
        case .themeAction:
            return .none
            
        case let .navigateTheme(value):
            state.navigateTheme = value
            state.themeState = value ? .init(themeType: state.themeType, entries: fakeEntries(with: state.styleType, layout: state.layoutType)) : nil
            return .none
            
        case let .iconAppAction(.iconAppChanged(iconAppChanged)):
            state.iconAppType = iconAppChanged
            
            return Effect(value: .iconAlternateIconChanged)
                .delay(for: 0.5, scheduler: environment.mainQueue)
                .eraseToEffect()
            
        case .iconAppAction:
            return .none
            
        case .iconAlternateIconChanged:
            if state.iconAppType == .dark {
                return environment.applicationClient.setAlternateIconName("AppIcon-2")
                    .fireAndForget()
            }
            return environment.applicationClient.setAlternateIconName(nil)
                .fireAndForget()
            
        case let .navigateIconApp(value):
            state.navigateIconApp = value
            state.iconAppState = value ? .init(iconAppType: state.iconAppType) : nil
            return .none
            
        case let .styleAction(.styleChanged(styleChanged)):
            state.styleType = styleChanged
            
            return environment.userDefaultsClient.set(styleType: styleChanged)
                .fireAndForget()
            
        case .styleAction:
            return .none
            
        case let .navigateStyle(value):
            state.navigateStyle = value
            state.styleState = value ? .init(styleType: state.styleType, layoutType: state.layoutType, entries: fakeEntries(with: state.styleType, layout: state.layoutType)) : nil
            return .none
            
        case let .layoutAction(.layoutChanged(layoutChanged)):
            state.layoutType = layoutChanged
            return environment.userDefaultsClient.set(layoutType: layoutChanged)
                .fireAndForget()
            
        case .layoutAction:
            return .none
            
        case let .navigateLayout(value):
            state.navigateLayout = value
            state.layoutState = value ? .init(layoutType: state.layoutType, styleType: state.styleType, entries: fakeEntries(with: state.styleType, layout: state.layoutType)) : nil
            return .none
        }
    }
)

public struct AppearanceView: View {
    let store: Store<AppearanceState, AppearanceAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                
                Form {
                    Section() {
                        HStack(spacing: 16) {
                            IconImageView(
                                systemName: "app",
                                foregroundColor: .orange
                            )
                            
                            Text("Settings.Style".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Text(viewStore.styleType.rawValue.localized)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.navigateStyle(true))
                        }
                        
                        HStack(spacing: 16) {
                            IconImageView(
                                systemName: "seal",
                                foregroundColor: .blue
                            )
                            
                            Text("Settings.Layout".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Text(viewStore.layoutType.rawValue.localized)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.navigateLayout(true))
                        }
                        
                        HStack(spacing: 16) {
                            IconImageView(
                                systemName: viewStore.themeType.icon,
                                foregroundColor: .berryRed
                            )
                            
                            Text("Settings.Theme".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Text(viewStore.themeType.rawValue.localized)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                            
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.navigateTheme(true))
                        }
                        
                        HStack(spacing: 16) {
                            IconImageView(
                                systemName: "app.fill",
                                foregroundColor: .yellow
                            )
                            
                            Text("Settings.Icon".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Spacer()
                            Text(viewStore.iconAppType.rawValue.localized)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.navigateIconApp(true))
                        }
                    }
                }
                
                VStack {
                    
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.themeState,
                                    action: AppearanceAction.themeAction
                                ),
                                then: ThemeView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateTheme,
                            send: AppearanceAction.navigateTheme)
                    )
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.iconAppState,
                                    action: AppearanceAction.iconAppAction
                                ),
                                then: IconAppView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateIconApp,
                            send: AppearanceAction.navigateIconApp)
                    )
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.styleState,
                                    action: AppearanceAction.styleAction
                                ),
                                then: StyleView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateStyle,
                            send: AppearanceAction.navigateStyle)
                    )
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.layoutState,
                                    action: AppearanceAction.layoutAction
                                ),
                                then: LayoutView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateLayout,
                            send: AppearanceAction.navigateLayout)
                    )
                    
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                }
                .frame(height: 0)
            }
        }
        .navigationBarTitle("Settings.Appearance".localized)
    }
}
