import SwiftUI

public protocol TextStyle {
	var font: LatoFonts { get }
	var size: CGFloat { get }
	var foregroundColor: Color { get }
}

public struct TitleTextStyle: TextStyle {
	public let font: LatoFonts = .latoBold
	public let size: CGFloat = 24
	public let foregroundColor: Color = .adaptiveBlack
}

public struct BodyTextStyle: TextStyle {
	public let font: LatoFonts
	public let size: CGFloat
	public let foregroundColor: Color
	
	public init(
		font: LatoFonts = .latoItalic,
		size: CGFloat = 12,
		foregroundColor: Color = .adaptiveGray
	) {
		self.font = font
		self.size = size
		self.foregroundColor = foregroundColor
	}
}

extension Text {
	public func textStyle(_ style: TextStyle) -> some View {
		self
			.adaptiveFont(style.font, size: style.size)
			.foregroundColor(style.foregroundColor)
	}
}

extension View {
	public func textStyle(_ style: TextStyle) -> some View {
		self
			.adaptiveFont(style.font, size: style.size)
			.foregroundColor(style.foregroundColor)
	}
}

extension TextStyle where Self == TitleTextStyle {
	static public var title: Self { TitleTextStyle() }
}

extension TextStyle where Self == BodyTextStyle {
	static public var body: Self { BodyTextStyle() }
	static public func body(
		_ foregroundColor: Color = .adaptiveGray
	) -> BodyTextStyle {
		BodyTextStyle(foregroundColor: foregroundColor)
	}
}

public struct ErrorTextStyle: TextStyle {
	public let font: LatoFonts = .latoItalic
	public let size: CGFloat = 12
	public let foregroundColor: Color = .berryRed
}

extension TextStyle where Self == ErrorTextStyle {
	static public var error: Self { ErrorTextStyle() }
}
