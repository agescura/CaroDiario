import SwiftUI

public struct NavigationSwitched<Content: View>: View {
	private let content: () -> Content
	
	public init(
		content: @escaping () -> Content
	) {
		self.content = content
	}
	
	public var body: some View {
		if #available(iOS 16.0, *) {
			NavigationStack { self.content() }
		} else {
			NavigationView { self.content() }
		}
	}
}
