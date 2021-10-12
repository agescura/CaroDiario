//
//  OnBoardingTabView.swift
//  
//
//  Created by Albert Gil Escura on 28/7/21.
//

import SwiftUI
import SharedStyles

public struct OnBoardingTabItem: Identifiable {
    public let id: Int
    public let title: String
}

public struct OnBoardingTabView: View {
    let items: [OnBoardingTabItem]
    let selection: Binding<Int>
    let animated: Bool
    
    public init(
        items: [OnBoardingTabItem],
        selection: Binding<Int>,
        animated: Bool
    ) {
        self.items = items
        self.selection = selection
        self.animated = animated
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.chambray)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.adaptiveGray)
    }
    
    public var body: some View {
        TabView(selection: selection) {
            ForEach(items) { item in
                OnBoardingItemTabView(item: item.title)
                    .tag(item.id)
            }
        }
        .multilineTextAlignment(.center)
        .adaptiveFont(.latoRegular, size: 16)
        .foregroundColor(.adaptiveWhite)
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .animation(animated ? .spring() : nil, value: UUID())
    }
}


public struct OnBoardingItemTabView: View {
    let item: String
    
    public init(
        item: String
    ) {
        self.item = item
    }
    
    public var body: some View {
        VStack {
            VStack {
                Text(item)
                    .adaptiveFont(.latoRegular, size: 16)
                    .foregroundColor(.adaptiveWhite)
            }
            .padding()
            .background(Color.adaptiveGray)
            .cornerRadius(4)
        }
    }
}
